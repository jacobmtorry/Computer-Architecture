#!/usr/bin/env python3
import subprocess
import re
import os
from datetime import datetime  # fine to keep even if not used directly

# ================================
# CONFIGURATION
# ================================

TEST_COMMANDS = [
    "make run_vcs_top_tb PROG=../testcode/coremark_im.elf",
    "make run_vcs_top_tb PROG=../testcode/cp3_release_benches/im/aes_sha.elf",
    "make run_vcs_top_tb PROG=../testcode/cp3_release_benches/im/compression.elf",
    "make run_vcs_top_tb PROG=../testcode/cp3_release_benches/im/fft.elf",
    "make run_vcs_top_tb PROG=../testcode/cp3_release_benches/im/mergesort.elf",
]

# how often to print progress (in committed instructions)
CHECKPOINT_STEP = 2500

# Set to 1 to collect power measurements, 0 to skip (saves time)
ENABLE_POWER = 1


# ================================
# RUN SIMULATION WITH PROGRESS
# ================================

def run_simulation(command: str) -> str:
    """
    Run the simulation, stream its output line by line, print a progress
    message every CHECKPOINT_STEP instructions, and return the full output.
    """
    print("\n[INFO] Running:\n  {}\n".format(command))

    # Start the process, merging stderr into stdout so we see everything
    proc = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,   # text mode (Py 3.6-compatible)
        bufsize=1,                 # line-buffered
    )

    output_lines = []
    next_checkpoint = CHECKPOINT_STEP
    commit_re = re.compile(r"dut commit No\.\s+([0-9]+)")
    commit_lines_seen = 0

    try:
        # Read the output as it is produced
        for raw_line in proc.stdout:
            line = raw_line.rstrip("\n")
            output_lines.append(line)

            # If you want to see sim output live, uncomment:
            # print(line)

            # Try to match commit lines
            m = commit_re.search(line)
            if m:
                commit_lines_seen += 1
                commit_no = int(m.group(1))

                # In case we skip past multiple checkpoints in one step,
                # use a while-loop
                while commit_no >= next_checkpoint:
                    print("[PROGRESS] {:,} instructions executed...".format(next_checkpoint))
                    next_checkpoint += CHECKPOINT_STEP

        proc.wait()
    finally:
        if proc.stdout is not None:
            proc.stdout.close()

    print("[INFO] Finished. Return code: {}".format(proc.returncode))
    print("[INFO] Detected {} commit lines in output.".format(commit_lines_seen))

    # Join all lines back into a single string for metric parsing
    return "\n".join(output_lines)


# ================================
# POWER COLLECTION
# ================================

def get_power() -> float:
    """
    Run the power flow:
        cd ../synth && make power_vcs && python get_power.py
    and return the numeric power value as a float (or None on failure).
    """
    print("[INFO] Running power flow: cd ../synth && make power_vcs && python get_power.py")
    
    # Save current directory
    original_dir = os.getcwd()
    synth_dir = os.path.join(original_dir, "..", "synth")
    
    try:
        # Change to synth directory
        os.chdir(synth_dir)
        
        # Run make power_vcs
        print("[INFO] Running: make power_vcs")
        make_result = subprocess.run(
            "make power_vcs",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        
        if make_result.returncode != 0:
            print("[WARN] make power_vcs failed with return code: {}".format(make_result.returncode))
            # Print last 20 lines for debugging
            lines = make_result.stdout.splitlines()
            tail = "\n".join(lines[-20:])
            print("[DEBUG] Last lines of make output:\n{}".format(tail))
            return None
        
        # Run python get_power.py
        print("[INFO] Running: python3 get_power.py")
        power_result = subprocess.run(
            "python3 get_power.py",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        
        stdout = power_result.stdout or ""
        stderr = power_result.stderr or ""
        
        if power_result.returncode != 0:
            print("[WARN] python3 get_power.py failed with return code: {}".format(power_result.returncode))
            print("[DEBUG] stderr:\n{}".format(stderr))
            return None
        
        # Parse the power value (should be a single number on stdout)
        # The script prints just the total power as a float
        power = None
        stdout_lines = stdout.strip().splitlines()
        
        if stdout_lines:
            # Get the last line (should be the power number)
            last_line = stdout_lines[-1].strip()
            try:
                power = float(last_line)
                print("[INFO] Parsed power: {:.6f} mW".format(power))
            except ValueError:
                print("[WARN] Could not parse power value '{}' as float".format(last_line))
                print("[DEBUG] Full stdout:\n{}".format(stdout))
        
        if power is None:
            print("[WARN] Could not parse power value from get_power.py output.")
            print("[DEBUG] stdout:\n{}".format(stdout))
            if stderr:
                print("[DEBUG] stderr:\n{}".format(stderr))
        
        return power
        
    finally:
        # Always return to original directory
        os.chdir(original_dir)


# ================================
# PARSE METRICS FROM OUTPUT
# ================================

def parse_metrics(output: str) -> dict:
    """
    Extract your three metrics from the simulation output.
    """
    ipc_match = re.search(r"Monitor:\s*Segment IPC:\s*([0-9]*\.[0-9]+)", output)
    time_match = re.search(r"Monitor:\s*Segment Time:\s*([0-9]+)", output)

    br_match = re.search(
        r"BR:\s*Flushes/Count\s*=\s*([0-9]+)/([0-9]+)\s*=\s*([0-9]*\.[0-9]+)",
        output,
    )

    metrics = {
        "segment_ipc": float(ipc_match.group(1)) if ipc_match else None,
        "segment_time": int(time_match.group(1)) if time_match else None,
        "br_flushes": int(br_match.group(1)) if br_match else None,
        "br_count": int(br_match.group(2)) if br_match else None,
        "br_ratio": float(br_match.group(3)) if br_match else None,
        "power": None,  # will be filled in later
    }

    return metrics


# ================================
# MAIN LOOP
# ================================

def main():
    results = []  # (prog_name, metrics) tuples

    for command in TEST_COMMANDS:
        # extract PROG=... for display
        match = re.search(r"PROG=([^\s]+)", command)
        prog_name = match.group(1) if match else "unknown"

        print("\n===============================================")
        print(" Running Test: {}".format(prog_name))
        print("===============================================")

        # 1) Run simulation + parse metrics
        sim_output = run_simulation(command)
        metrics = parse_metrics(sim_output)

        # 2) Run power flow + add to metrics (if enabled)
        if ENABLE_POWER:
            power_val = get_power()
            metrics["power"] = power_val
        else:
            print("[INFO] Power collection disabled (ENABLE_POWER=0)")
            metrics["power"] = None

        results.append((prog_name, metrics))

    # final summary
    print("\n\n###############################################")
    print(" ALL TESTS COMPLETE — SUMMARY")
    print("###############################################")

    for prog, m in results:
        print("\nProgram: {}".format(prog))
        print("  Segment IPC:   {}".format(m["segment_ipc"]))
        print("  Segment Time:  {}".format(m["segment_time"]))
        print("  BR Flushes:    {} / {}  Ratio={}".format(
            m["br_flushes"], m["br_count"], m["br_ratio"])
        )

        if m["power"] is None:
            print("  Power:         None")
        else:
            print("  Power:         {:.6f}".format(m["power"]))

    print("\n[INFO] Done.\n")


if __name__ == "__main__":
    main()
