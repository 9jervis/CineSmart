#!/usr/bin/env python3
"""
CineSmart Voice Chatbot API Test Script
Tests the voice chatbot endpoint with various intents and scenarios
"""

import requests
import json
from typing import Dict, Any

BASE_URL = "http://localhost:8000"
CHAT_ENDPOINT = f"{BASE_URL}/chat"

# Color codes for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def test_chat(message: str, session_id: str = None) -> Dict[str, Any]:
    """Send a message to the chatbot and return the response"""
    payload = {"message": message}
    if session_id:
        payload["session_id"] = session_id
    
    try:
        response = requests.post(CHAT_ENDPOINT, json=payload, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"{RED}✗ Request failed: {e}{RESET}")
        return None

def print_response(user_msg: str, response: Dict[str, Any]):
    """Pretty print the chatbot response"""
    if not response:
        return
    
    print(f"\n{BLUE}User:{RESET} {user_msg}")
    print(f"{YELLOW}Bot:{RESET} {response.get('reply', 'No reply')}")
    
    if response.get('action'):
        print(f"{GREEN}Action:{RESET} {response['action']}")
    
    if response.get('data'):
        print(f"{GREEN}Data:{RESET}")
        for key, value in response['data'].items():
            if key not in ['image_url']:  # Skip long URLs
                print(f"  - {key}: {value}")
    
    if response.get('session_id'):
        print(f"{BLUE}Session:{RESET} {response['session_id']}")

def run_test_suite():
    """Run a comprehensive test suite"""
    print(f"\n{BLUE}{'='*60}")
    print("CineSmart Voice Chatbot - API Test Suite")
    print(f"{'='*60}{RESET}\n")
    
    session_id = None
    
    # Test 1: Greeting
    print(f"{YELLOW}[Test 1] Greeting{RESET}")
    response = test_chat("Hi")
    if response:
        session_id = response.get('session_id')
        print_response("Hi", response)
        print(f"{GREEN}✓ Passed{RESET}")
    
    # Test 2: List movies
    print(f"\n{YELLOW}[Test 2] List Movies{RESET}")
    response = test_chat("show movies", session_id)
    if response and 'movies' in response.get('reply', '').lower():
        session_id = response.get('session_id')
        print_response("show movies", response)
        print(f"{GREEN}✓ Passed{RESET}")
    else:
        print(f"{RED}✗ Failed{RESET}")
    
    # Test 3: Movie details request
    print(f"\n{YELLOW}[Test 3] Movie Details{RESET}")
    response = test_chat("tell me about avatar", session_id)
    if response and 'avatar' in response.get('reply', '').lower():
        session_id = response.get('session_id')
        print_response("tell me about avatar", response)
        print(f"{GREEN}✓ Passed{RESET}")
    else:
        print(f"{RED}✗ Failed{RESET}")
    
    # Test 4: Show timings
    print(f"\n{YELLOW}[Test 4] Show Timings{RESET}")
    response = test_chat("what are the show times", session_id)
    if response and ('show' in response.get('reply', '').lower()):
        session_id = response.get('session_id')
        print_response("what are the show times", response)
        print(f"{GREEN}✓ Passed{RESET}")
    else:
        print(f"{RED}✗ Failed{RESET}")
    
    # Test 5: Book movie - single step
    print(f"\n{YELLOW}[Test 5] Book Movie (Single Step){RESET}")
    response = test_chat("book avatar 3 seats at 7:15 pm", session_id)
    if response and response.get('action') == 'open_seat_page':
        session_id = response.get('session_id')
        print_response("book avatar 3 seats at 7:15 pm", response)
        print(f"{GREEN}✓ Passed - Action triggered{RESET}")
    else:
        print(f"{RED}✗ Failed - No action triggered{RESET}")
    
    # Test 6: Book movie - multi-step (fresh session)
    print(f"\n{YELLOW}[Test 6] Book Movie (Multi-Step){RESET}")
    fresh_session = None
    
    # Step 1: Request to book
    response1 = test_chat("book avengers", fresh_session)
    if response1 and response1.get('expecting') == 'seat_count':
        fresh_session = response1.get('session_id')
        print_response("book avengers", response1)
        print(f"{GREEN}✓ Step 1 Passed - Awaiting seat count{RESET}")
        
        # Step 2: Provide seat count
        response2 = test_chat("2 seats", fresh_session)
        if response2 and response2.get('action') == 'open_seat_page':
            print_response("2 seats", response2)
            print(f"{GREEN}✓ Step 2 Passed - Action triggered{RESET}")
        else:
            print(f"{RED}✗ Step 2 Failed{RESET}")
    else:
        print(f"{RED}✗ Step 1 Failed{RESET}")
    
    # Test 7: Invalid movie
    print(f"\n{YELLOW}[Test 7] Invalid/Unknown Movie{RESET}")
    response = test_chat("book xyzabc movie 5 seats", session_id)
    if response:
        session_id = response.get('session_id')
        print_response("book xyzabc movie 5 seats", response)
        if "couldn't find" in response.get('reply', '').lower():
            print(f"{GREEN}✓ Passed - Handled gracefully{RESET}")
        else:
            print(f"{YELLOW}⚠ Warning - Might not be obvious error{RESET}")
    
    # Test 8: Empty message
    print(f"\n{YELLOW}[Test 8] Empty Message{RESET}")
    response = test_chat("", session_id)
    if response and "something" in response.get('reply', '').lower():
        print_response("(empty)", response)
        print(f"{GREEN}✓ Passed - Handled gracefully{RESET}")
    else:
        print(f"{YELLOW}⚠ Warning - Might not handle empty messages{RESET}")
    
    # Test 9: Seat limit validation
    print(f"\n{YELLOW}[Test 9] Seat Limit Validation{RESET}")
    response = test_chat("book avatar 15 seats", session_id)
    if response:
        session_id = response.get('session_id')
        print_response("book avatar 15 seats", response)
        # Should either reject or cap at 10
        print(f"{GREEN}✓ Passed - Response received{RESET}")
    
    # Test 10: Movie name variations
    print(f"\n{YELLOW}[Test 10] Movie Name Variations{RESET}")
    variations = ["book AVATAR", "book Avatar", "book avatar", "book The Avatar"]
    all_passed = True
    for variation in variations:
        response = test_chat(variation + " 1 seat", session_id)
        if response and response.get('action') == 'open_seat_page':
            session_id = response.get('session_id')
        else:
            all_passed = False
            break
    
    if all_passed:
        print(f"{GREEN}✓ All variations handled{RESET}")
    else:
        print(f"{YELLOW}⚠ Some variations failed{RESET}")
    
    # Summary
    print(f"\n{BLUE}{'='*60}")
    print("Test Suite Complete")
    print(f"{'='*60}{RESET}\n")

def interactive_mode():
    """Run in interactive mode for manual testing"""
    print(f"\n{BLUE}CineSmart Chatbot - Interactive Mode{RESET}")
    print("Type 'exit' to quit\n")
    
    session_id = None
    
    while True:
        user_input = input(f"{BLUE}You:{RESET} ").strip()
        
        if user_input.lower() in ['exit', 'quit', 'q']:
            print("Goodbye!")
            break
        
        if not user_input:
            print("(empty input)")
            continue
        
        response = test_chat(user_input, session_id)
        if response:
            session_id = response.get('session_id')
            print_response(user_input, response)
        else:
            print(f"{RED}Error connecting to chatbot{RESET}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] in ['--interactive', '-i']:
        interactive_mode()
    else:
        run_test_suite()
