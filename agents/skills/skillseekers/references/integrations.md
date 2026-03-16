# Skillseekersweb - Integrations

**Pages:** 15

---

## RAG & Vector Databases | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Build production RAG systems that transform any source into searchable knowledge.

Retrieval-Augmented Generation = Vector Database + Retrieval + LLM

The Problem: 70% of RAG development is data preprocessing.

The Solution: Skill Seekers automates it all—extract, chunk, embed, store.

5-Minute RAG Pipeline →

**Examples:**

Example 1 (sql):
```sql
# From documentation
skill-seekers scrape --format langchain --config react.json

# From GitHub repo
skill-seekers scrape --format langchain --github owner/repo

# From PDF
skill-seekers scrape --format langchain --pdf manual.pdf

# From codebase
skill-seekers analyze --format langchain --directory ./project
```

Example 2 (swift):
```swift
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌─────────┐
│   Source    │────▶│Skill Seekers │────▶│ Vector DB   │────▶│   LLM   │
│(Any Source) │     │(Chunk/Embed) │     │(Pinecone/  │     │(Answer) │
└─────────────┘     └──────────────┘     │ Chroma/etc) │     └─────────┘
                                          └─────────────┘
```

---

## Cursor | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/coding/cursor

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Give Cursor IDE complete framework knowledge with .cursorrules.

**Examples:**

Example 1 (sql):
```sql
# From documentation
skill-seekers scrape --target claude --config configs/react.json
cp output/react-claude/.cursorrules ./

# From GitHub repo (better!)
skill-seekers scrape --target claude --github https://github.com/facebook/react
cp output/react-claude/.cursorrules ./
```

Example 2 (unknown):
```unknown
skill-seekers scrape --config configs/react.json --target claude
```

Example 3 (unknown):
```unknown
cp output/react-claude/.cursorrules ./my-project/
```

Example 4 (lua):
```lua
function handleClick() {
  // Generic suggestion...
}
```

---

## Chroma | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/chroma

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Direct export to Chroma vector database—perfect for local development.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format chroma --config configs/react.json
```

Example 2 (sass):
```sass
import chromadb

# Connect to Chroma
client = chromadb.PersistentClient(path="./chroma_db")

# Get collection
collection = client.get_collection("react-docs")

# Query
results = collection.query(
    query_texts=["How do I use useState?"],
    n_results=3
)

print(results['documents'][0])
```

Example 3 (sass):
```sass
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma(
    collection_name="react-docs",
    embedding_function=OpenAIEmbeddings(),
    persist_directory="./chroma_db"
)

results = vectorstore.similarity_search("React Hooks")
```

---

## LangChain | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/langchain

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Transform any source into LangChain Documents for RAG pipelines.

Each document includes:

**Examples:**

Example 1 (sql):
```sql
# From documentation
skill-seekers scrape --format langchain --config configs/react.json

# From GitHub repo
skill-seekers scrape --format langchain --github https://github.com/facebook/react

# From PDF
skill-seekers scrape --format langchain --pdf ./manual.pdf

# From local codebase
skill-seekers analyze --directory ./my-project --format langchain
```

Example 2 (python):
```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain.schema import Document
import json

# Load documents from Skill Seekers output
def load_documents(output_dir):
    """Load documents from Skill Seekers LangChain output."""
    documents = []
    with open(f"{output_dir}/documents.json", "r") as f:
        data = json.load(f)
        for doc in data:
            documents.append(Document(
                page_content=doc["content"],
                metadata=doc["metadata"]
            ))
    return documents

# Load documents
documents = load_documents("output/react-langchain/")
print(f"Loaded {len(documents)} documents")

# Create vector store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(
    documents,
    embeddings,
    collection_name="react-docs"
)

# Query
results = vectorstore.similarity_search("How do I use useState?")
print(results[0].page_content)
```

Example 3 (json):
```json
{
  "page_content": "...",
  "metadata": {
    "source": "https://react.dev/docs/hooks-intro",
    "title": "Introducing Hooks",
    "category": "api",
    "language": "javascript"
  }
}
```

Example 4 (python):
```python
from langchain.chains import RetrievalQA
from langchain_openai import ChatOpenAI

# Create QA chain with modern ChatOpenAI
qa_chain = RetrievalQA.from_chain_type(
    llm=ChatOpenAI(model="gpt-4o"),
    chain_type="stuff",
    retriever=vectorstore.as_retriever()
)

# Ask questions
response = qa_chain.invoke({"query": "What are React Hooks?"})
print(response["result"])
```

---

## AI Coding Assistants | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/coding

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Give your IDE expert framework knowledge. Transform docs, repos, and codebases into AI coding rules.

Your AI coding assistant doesn’t know your frameworks:

Convert any source into .cursorrules, .windsurfrules, etc.:

Give Cursor Framework Knowledge →

**Examples:**

Example 1 (sql):
```sql
# From documentation
skill-seekers scrape --target claude --config react.json
cp output/react-claude/.cursorrules ./

# From GitHub repo (better!)
skill-seekers scrape --target claude --github facebook/react
cp output/react-claude/.cursorrules ./
```

Example 2 (lua):
```lua
function handleClick() {
  // Generic suggestion...
}
```

Example 3 (jsx):
```jsx
function Counter() {
  const [count, setCount] = useState(0);  // Suggests useState
  
  useEffect(() => {  // Knows lifecycle
    document.title = `Count: ${count}`;
  }, [count]);
  
  return <button onClick={() => setCount(c => c + 1)}>  // Knows patterns
    Count: {count}
  </button>;
}
```

---

## Haystack | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/haystack

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Enterprise RAG with Haystack 2.x—production NLP pipelines.

For semantic search with embeddings:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format haystack --config configs/react.json
```

Example 2 (sass):
```sass
pip install haystack-ai>=2.0.0
```

Example 3 (python):
```python
from haystack import Document, Pipeline
from haystack.document_stores.in_memory import InMemoryDocumentStore
from haystack.components.retrievers import InMemoryBM25Retriever
from haystack.components.generators import OpenAIGenerator
from haystack.components.builders import PromptBuilder
import json

# Load documents from Skill Seekers output
def load_documents(output_dir):
    documents = []
    with open(f"{output_dir}/documents.json", "r") as f:
        data = json.load(f)
        for item in data:
            documents.append(Document(
                content=item["content"],
                meta=item.get("metadata", {})
            ))
    return documents

# Create document store and load documents
document_store = InMemoryDocumentStore()
docs = load_documents("output/react-haystack/")
document_store.write_documents(docs)

# Create RAG pipeline
prompt_template = """
Given these documents, answer the question.
Documents:
{% for doc in documents %}
  {{ doc.content }}
{% endfor %}

Question: {{question}}
Answer:
"""

retriever = InMemoryBM25Retriever(document_store=document_store)
prompt_builder = PromptBuilder(template=prompt_template)
llm = OpenAIGenerator(model="gpt-4o")

# Build pipeline
rag_pipeline = Pipeline()
rag_pipeline.add_component("retriever", retriever)
rag_pipeline.add_component("prompt_builder", prompt_builder)
rag_pipeline.add_component("llm", llm)

# Connect components
rag_pipeline.connect("retriever.documents", "prompt_builder.documents")
rag_pipeline.connect("prompt_builder.prompt", "llm.prompt")

# Query
result = rag_pipeline.run(
    {
        "retriever": {"query": "What are React Hooks?"},
        "prompt_builder": {"question": "What are React Hooks?"}
    }
)
print(result["llm"]["replies"][0])
```

Example 4 (lua):
```lua
from haystack.components.embedders import OpenAIDocumentEmbedder, OpenAITextEmbedder
from haystack.components.retrievers import InMemoryEmbeddingRetriever

# Create embedding retriever pipeline
embedding_pipeline = Pipeline()
embedding_pipeline.add_component("embedder", OpenAIDocumentEmbedder())
embedding_pipeline.add_component("retriever", InMemoryEmbeddingRetriever(document_store=document_store))

# First, embed documents
docs_with_embeddings = embedding_pipeline.run({"documents": docs})
document_store.write_documents(docs_with_embeddings["retriever"]["documents"])

# Query with embeddings
query_pipeline = Pipeline()
query_pipeline.add_component("text_embedder", OpenAITextEmbedder())
query_pipeline.add_component("retriever", InMemoryEmbeddingRetriever(document_store=document_store))
query_pipeline.connect("text_embedder.embedding", "retriever.query_embedding")

result = query_pipeline.run({"text_embedder": {"text": "React Hooks"}})
for doc in result["retriever"]["documents"]:
    print(f"Score: {doc.score:.3f} - {doc.content[:200]}...")
```

---

## Pinecone | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/pinecone

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Production-ready vector search with Pinecone cloud database.

Get API Key from Pinecone Console

Install dependencies:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format pinecone --config configs/react.json
```

Example 2 (unknown):
```unknown
pip install pinecone-client
```

Example 3 (typescript):
```typescript
from pinecone import Pinecone, ServerlessSpec
import json

# Initialize
pc = Pinecone(api_key="your-api-key")

# Create index
index = pc.Index("react-docs")

# Load and upsert data
with open("output/react-pinecone.json") as f:
    data = json.load(f)
    
index.upsert(vectors=data)
```

Example 4 (sass):
```sass
# Query
results = index.query(
    vector=embedding,
    top_k=5,
    filter={"category": "api"}
)
```

---

## Cline | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/coding/cline

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

VS Code extension with MCP support for advanced AI coding.

From VS Code Extensions marketplace.

This enables natural language commands in Cline:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --target claude --config configs/react.json
cp output/react-claude/.clinerules ./
```

Example 2 (unknown):
```unknown
skill-seekers scrape --config configs/react.json --target claude
```

Example 3 (unknown):
```unknown
cp output/react-claude/.clinerules ./my-project/
```

Example 4 (unknown):
```unknown
cd /path/to/Skill_Seekers
./setup_mcp.sh
```

---

## LlamaIndex | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/llamaindex

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Transform any source into LlamaIndex TextNodes for query engines and chatbots.

**Examples:**

Example 1 (sql):
```sql
# From any source
skill-seekers scrape --format llama-index --config configs/react.json
```

Example 2 (swift):
```swift
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

# Load documents
reader = SimpleDirectoryReader("output/react-llama-index/")
documents = reader.load_data()

# Create index
index = VectorStoreIndex.from_documents(documents)

# Create query engine
query_engine = index.as_query_engine()

# Query
response = query_engine.query("What are React Hooks?")
print(response)
```

Example 3 (sql):
```sql
# Chat engine is accessed directly from the index
chat_engine = index.as_chat_engine()
response = chat_engine.chat("Explain useEffect")
print(response)
```

---

## Windsurf | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/coding/windsurf

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Give Windsurf IDE framework knowledge with .windsurfrules.

Windsurf has a 12K limit. For large frameworks:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --target claude --config configs/react.json
cp output/react-claude/.windsurfrules ./
```

Example 2 (unknown):
```unknown
skill-seekers scrape --config configs/react.json --target claude
```

Example 3 (unknown):
```unknown
cp output/react-claude/.windsurfrules ./my-project/
```

---

## Weaviate | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/weaviate

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Enterprise vector search with Weaviate—GraphQL interface and modular AI.

For production, use Weaviate Cloud:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format weaviate --config configs/react.json
```

Example 2 (sass):
```sass
pip install weaviate-client>=4.0.0
```

Example 3 (typescript):
```typescript
import weaviate
import json

# Connect to local Weaviate
client = weaviate.connect_to_local()

# Load data
with open("output/react-weaviate.json") as f:
    data = json.load(f)

# Create collection if it doesn't exist
from weaviate.classes.config import Configure, Property, DataType

if not client.collections.exists("ReactDoc"):
    client.collections.create(
        name="ReactDoc",
        vectorizer_config=Configure.Vectorizer.none(),  # We'll provide vectors
        properties=[
            Property(name="content", data_type=DataType.TEXT),
            Property(name="category", data_type=DataType.TEXT),
            Property(name="source", data_type=DataType.TEXT),
        ]
    )

# Get collection
collection = client.collections.get("ReactDoc")

# Import data with embeddings
with collection.batch.dynamic() as batch:
    for item in data:
        batch.add_object(
            properties={
                "content": item["content"],
                "category": item.get("category", ""),
                "source": item.get("source", "")
            },
            vector=item["embedding"]
        )

client.close()
```

Example 4 (lua):
```lua
import weaviate

client = weaviate.connect_to_local()
collection = client.collections.get("ReactDoc")

# Vector search
response = collection.query.near_text(
    query="React Hooks",
    limit=3,
    return_properties=["content", "category", "source"]
)

for obj in response.objects:
    print(f"Content: {obj.properties['content'][:200]}...")
    print(f"Category: {obj.properties['category']}")
    print("---")

client.close()
```

---

## Continue.dev | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/coding/continue

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Universal AI coding plugin for VS Code, JetBrains, Vim.

From your IDE’s plugin marketplace.

Add to ~/.continue/config.json:

Type @react-docs in Continue chat to reference the framework knowledge.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --target markdown --config configs/react.json
```

Example 2 (unknown):
```unknown
skill-seekers scrape --config configs/react.json --target markdown
```

Example 3 (json):
```json
{
  "contextProviders": [
    {
      "name": "react-docs",
      "type": "file",
      "file": "/path/to/output/react-markdown/SKILL.md"
    }
  ]
}
```

---

## Integrations | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Connect Skill Seekers to 16+ AI systems organized by use case.

Build production search and Q&A systems.

Give your IDE framework expertise.

**Examples:**

Example 1 (markdown):
```markdown
# Same source, different outputs
skill-seekers scrape --config react.json --format langchain
skill-seekers scrape --config react.json --format llama-index
skill-seekers scrape --config react.json --target claude  # For Cursor
```

---

## Qdrant | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/qdrant

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

High-performance vector search with Qdrant—Rust engine, advanced filtering.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format qdrant --config configs/react.json
```

Example 2 (unknown):
```unknown
pip install qdrant-client
```

Example 3 (typescript):
```typescript
from qdrant_client import QdrantClient
import json

# Connect
client = QdrantClient(host="localhost", port=6333)

# Load and upload
with open("output/react-qdrant.json") as f:
    data = json.load(f)
    
client.upsert(
    collection_name="react-docs",
    points=data
)
```

Example 4 (sass):
```sass
from qdrant_client.models import Filter, FieldCondition, Match

# Search with filter
results = client.search(
    collection_name="react-docs",
    query_vector=embedding,
    query_filter=Filter(
        must=[FieldCondition(
            key="category",
            match=Match(value="api")
        )]
    ),
    limit=5
)
```

---

## FAISS | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/integrations/rag/faiss

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Facebook AI Similarity Search—high-performance local vector search.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --format faiss --config configs/react.json
```

Example 2 (unknown):
```unknown
pip install faiss-cpu  # or faiss-gpu
```

Example 3 (typescript):
```typescript
import faiss
import numpy as np
import json

# Load data
with open("output/react-faiss.json") as f:
    data = json.load(f)

# Build index
dimension = 1536  # OpenAI embedding size
index = faiss.IndexFlatL2(dimension)

# Add vectors
vectors = np.array([d['vector'] for d in data]).astype('float32')
index.add(vectors)

# Search
query = np.random.random((1, dimension)).astype('float32')
distances, indices = index.search(query, k=5)

print(f"Nearest neighbors: {indices[0]}")
```

---
