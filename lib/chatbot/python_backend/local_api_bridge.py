# local_api_bridge.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import sys
from local_llm import LocalLLM  # Import your real local LLM

app = Flask(__name__)
CORS(app)  # Enable CORS for all origins

# Setup logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)

# Initialize your LLM (you can change model_name if needed)
llm = LocalLLM(model="phi")

@app.route("/generate", methods=["POST"])
def generate():
    try:
        data = request.get_json()
        prompt = data.get("prompt", "")
        model = data.get("model", "phi")

        logging.info(f"Received prompt: {prompt}")

        # Call your LocalLLM
        from local_llm import LocalLLM
        llm = LocalLLM(model=model)
        response_text = llm.generate_response(prompt)

        return jsonify({"response": response_text, "text": response_text, "emotion": "neutral"})

    except Exception as e:
        logging.exception("Exception during request:")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500


if __name__ == "__main__":
    # Run on all interfaces for flexibility (Flutter Web or devices)
    app.run(host="0.0.0.0", port=5000, debug=True)
