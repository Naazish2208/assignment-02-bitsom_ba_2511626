## Vector DB Use Case

Keyword Search vs. Vector Database for Contract Q&A

A traditional keyword-based search would fall significantly short for this use case. Keyword systems match exact or near-exact terms, meaning a query like "What are the termination clauses?" would only surface paragraphs containing the literal word "termination." However, contracts routinely express the same concept through varied language — "right to dissolve," "notice of expiry," "exit provisions," or "grounds for cancellation" — none of which would be retrieved. Lawyers would be forced to anticipate every possible phrasing, making the system brittle and unreliable on 500-page documents where precision is non-negotiable.

This is precisely the gap a vector database fills. The system would first chunk each contract into smaller passages and encode them into high-dimensional embeddings using a model like all-MiniLM-L6-v2 or a legal-domain fine-tuned transformer. These embeddings capture semantic meaning, not just surface tokens. The lawyer's plain-English query is encoded the same way, and the vector database (e.g., Pinecone, Weaviate, or pgvector) performs an approximate nearest-neighbour search to retrieve passages whose meaning is closest to the query — regardless of exact wording.

The retrieved passages are then passed to a large language model to synthesise a coherent, cited answer. This architecture — known as Retrieval-Augmented Generation (RAG) — gives the system both recall (finding semantically relevant clauses) and accuracy (grounding responses in actual contract text). For a law firm, where missing a single clause can have serious consequences, semantic retrieval via a vector database is not optional — it is foundational.
