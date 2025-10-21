# local_llm.py
import ollama

class LocalLLM:
    def __init__(self, model="phi"):
        self.model = model

    def generate_response(self, prompt):
        """
        Calls the local Ollama model and returns response text.
        """
        try:
            response = ollama.generate(model=self.model, prompt=prompt)
            # response is usually a dict with 'response' key
            text = response.get("response", "") if isinstance(response, dict) else str(response)
            return text
        except Exception as e:
            return f"⚠️ Error generating response: {e}"
