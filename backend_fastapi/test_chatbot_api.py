"""Test script for the chatbot API."""
import requests
import json
from typing import Dict, Any

# Configuration
BASE_URL = "http://localhost:8000/api/chat"


def test_chat_endpoint(message: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
    """Test the chat endpoint with a message."""
    url = f"{BASE_URL}/message"
    payload = {
        "message": message,
        "movie_context": None,
        "booking_context": context or {}
    }
    
    print(f"\n{'='*60}")
    print(f"Testing: {message}")
    print(f"{'='*60}")
    print(f"Request: {json.dumps(payload, indent=2)}")
    
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        result = response.json()
        print(f"\nResponse: {json.dumps(result, indent=2)}")
        return result
    except Exception as e:
        print(f"Error: {e}")
        return {}


def test_movies_endpoint() -> Dict[str, Any]:
    """Test the movies endpoint."""
    url = f"{BASE_URL}/movies"
    
    print(f"\n{'='*60}")
    print("Testing: Get Available Movies")
    print(f"{'='*60}")
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        result = response.json()
        print(f"Response: {json.dumps(result, indent=2)}")
        return result
    except Exception as e:
        print(f"Error: {e}")
        return {}


def run_test_suite():
    """Run a comprehensive test suite."""
    print("\n" + "="*60)
    print("CHATBOT API TEST SUITE")
    print("="*60)
    
    # Test 1: Get available movies
    print("\nTest 1: Get Available Movies")
    movies_result = test_movies_endpoint()
    
    # Test 2: Book with all details
    print("\nTest 2: Book with All Details")
    test_chat_endpoint("Book 3 seats for Avatar")
    
    # Test 3: Book movie only
    print("\nTest 3: Book Movie Only")
    result = test_chat_endpoint("Book Inception")
    context = result.get('context_update', {})
    
    # Test 4: Provide seat count
    print("\nTest 4: Provide Seat Count")
    test_chat_endpoint("5 seats", context)
    
    # Test 5: Show movies
    print("\nTest 5: Show Movies")
    test_chat_endpoint("Show me movies")
    
    # Test 6: Show specific movie details
    print("\nTest 6: Show Movie Details")
    test_chat_endpoint("Tell me about The Matrix")
    
    # Test 7: Confirmation
    print("\nTest 7: Confirmation")
    test_chat_endpoint("Yes, book it")
    
    # Test 8: General query
    print("\nTest 8: General Query")
    test_chat_endpoint("What can you do?")
    
    # Test 9: Complex booking
    print("\nTest 9: Complex Booking")
    test_chat_endpoint("I want to book 2 tickets for Dune")
    
    # Test 10: Seat selection
    print("\nTest 10: Seat Selection")
    test_chat_endpoint("I'll take seats A1, A2, and A3")
    
    print("\n" + "="*60)
    print("TEST SUITE COMPLETED")
    print("="*60 + "\n")


if __name__ == "__main__":
    run_test_suite()
