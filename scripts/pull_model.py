from transformers import AutoModelForSequenceClassification, AutoTokenizer

model_name = "winegarj/distilbert-base-uncased-finetuned-sst2"

# Download and cache the model and tokenizer
model = AutoModelForSequenceClassification.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Save the model and tokenizer in the root directory
model.save_pretrained('./distilbert-base-uncased-finetuned-sst2')
tokenizer.save_pretrained('./distilbert-base-uncased-finetuned-sst2')