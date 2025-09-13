#!/usr/bin/env python3
"""
Simple launcher script for the fitness analysis system
"""
import sys
import subprocess
import threading
import time

def start_height_server():
    """Start the height assessment server"""
    try:
        subprocess.run([sys.executable, "height_assessment_server.py"], check=True)
    except Exception as e:
        print(f"Failed to start height server: {e}")

def start_fitness_tracker():
    """Start the fitness tracker GUI"""
    try:
        subprocess.run([sys.executable, "fitness_tracker.py"], check=True)
    except Exception as e:
        print(f"Failed to start fitness tracker: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python launcher.py [server|tracker|both]")
        sys.exit(1)
    
    mode = sys.argv[1].lower()
    
    if mode == "server":
        print("Starting height assessment server...")
        start_height_server()
    elif mode == "tracker":
        print("Starting fitness tracker...")
        start_fitness_tracker()
    elif mode == "both":
        print("Starting both server and tracker...")
        # Start server in background thread
        server_thread = threading.Thread(target=start_height_server, daemon=True)
        server_thread.start()
        
        # Wait a moment for server to start
        time.sleep(2)
        
        # Start tracker in main thread
        start_fitness_tracker()
    else:
        print("Invalid mode. Use: server, tracker, or both")
        sys.exit(1)

if __name__ == "__main__":
    main()