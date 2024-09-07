from langchain_community.document_loaders import PyPDFLoader
from langchain_community.document_loaders import Docx2txtLoader
from langchain.document_loaders import TextLoader
import os
import getpass
from langchain.text_splitter import RecursiveCharacterTextSplitter
from semantic_router.encoders import OpenAIEncoder
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
import time
from pinecone import ServerlessSpec
import faiss
import os
import numpy as np
import pandas as pd
from tqdm import tqdm
import pandas as pd
import csv
from openai import OpenAI
from pinecone import Pinecone
from sentence_transformers import SentenceTransformer

folder_path = "data"
split_lines = []

# Define a text splitter that splits by paragraph
def get_paragraph_splitter():
    return RecursiveCharacterTextSplitter(
        chunk_size=1000,  # Adjust this based on your needs
        chunk_overlap=50,  # If you want no overlap between chunks
        separators=["\n\n", "\n", ".", " "]  # First try splitting by paragraph, then by newline, then by sentence
    )

splitter = get_paragraph_splitter()

def chunker(splitter,docs):
    chunks = []
    for doc in docs:
        doc_chunks = splitter.split_text(doc)  # Split the document text into chunks
        chunks.extend(doc_chunks)
    return chunks

for filename in os.listdir(folder_path):
    file_path = os.path.join(folder_path, filename)

    # Load the file based on its type
    if filename.endswith(".pdf"):
        loader = PyPDFLoader(file_path)
    elif filename.endswith(".docx"):
        loader = Docx2txtLoader(file_path)
    elif filename.endswith(".txt"):
        loader = TextLoader(file_path)
    else:
        continue

    # Load the document and attach metadata
    pages = loader.load()
    for page in pages:
        metadata = {"source": filename}

        # Process the chunks for each page content
        chunks = chunker(docs=[page.page_content])  # Use the chunker with the page content
        for chunk in chunks:
            split_lines.append((chunk, metadata))


# Write split lines with metadata to CSV
with open('split_text.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(["text", "source"])  # Add headers for metadata
    for text, metadata in split_lines:
        writer.writerow([text, metadata["source"]])

dataset = pd.read_csv("split_text.csv", quotechar='"', escapechar='\\')

# SentenceTransformer encoder tanımlıyoruz
encoder = SentenceTransformer('all-MiniLM-L6-v2')  # Küçük ve hızlı bir model

def get_embedding(sentence):
    return encoder.encode(sentence).tolist()  # Embedding'i numpy array yerine list olarak döndürüyoruz

# Embedding'lerin oluşturulması
if os.path.exists("embedded_splits.csv"):
    dataset = pd.read_csv("embedded_splits.csv")
    dataset["embedding"] = dataset.embedding.apply(eval).apply(np.array)
else:
    tqdm.pandas()
    dataset["embedding"] = dataset["text"].progress_apply(get_embedding)
    dataset.to_csv("embedded_splits.csv", index=False)

dataset["id"] = range(1, len(dataset) + 1)
dataset.head()

embedding_dimension = len(dataset.iloc[0]["embedding"])
embeddings = np.array(dataset.embedding.tolist())

# FAISS ile indeksleme
index_l2 = faiss.IndexFlatL2(embedding_dimension)
index_l2.add(embeddings)
xq = np.random.rand(embedding_dimension).astype("float32")  # Example query vector
_, document_indices = index_l2.search(np.expand_dims(xq, axis=0), k=10)


# Pinecone Ayarları
PINECONE_API_KEY = "5a23123c-6de1-48e1-8788-abcc204ebe82"
database = Pinecone(api_key=PINECONE_API_KEY)

serverless_spec = ServerlessSpec(cloud="aws", region="us-east-1")

ders_adi = "cografya"
INDEX_NAME = ders_adi

if INDEX_NAME not in database.list_indexes().names():
    database.create_index(
        name=INDEX_NAME,
        dimension=embedding_dimension,
        metric="cosine",
        spec=serverless_spec,
    )

    time.sleep(1)

pinecone_index = database.Index(INDEX_NAME)

def iterator(dataset, size):
    for i in range(0, len(dataset), size):
        yield dataset.iloc[i : i + size]

def vector(batch):
    vector = []
    for i in batch.to_dict("records"):
        vector.append((str(i["id"]), i["embedding"], {"text": i["text"], "source": i["source"]}))
    return vector

if pinecone_index.describe_index_stats()["total_vector_count"] == 0:
    for batch in iterator(dataset, 100):
        pinecone_index.upsert(vector(batch))

pinecone_index.describe_index_stats()

