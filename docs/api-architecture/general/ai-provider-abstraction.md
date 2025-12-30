# AI Provider Abstraction Layer - Implementation Guide

## 🎯 PURPOSE

Enable ORIN to **start with FREE local AI models** and **seamlessly upgrade to PAID cloud APIs** without code rewrites.

**Key Principle:** All AI functionality goes through abstraction interfaces, making provider switching a configuration change, not a code change.

---

## 🏗️ ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────┐
│                   ORIN Application                      │
│   (Guard Agent, Chat, Summarization, Rule Compiler)    │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ↓
┌─────────────────────────────────────────────────────────┐
│              ABSTRACTION INTERFACES                     │
│  - LLMProvider (text generation)                        │
│  - EmbeddingProvider (vector embeddings)                │
│  - VisionProvider (image understanding)                 │
└───────────────────┬─────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        ↓                       ↓
┌───────────────┐      ┌───────────────┐
│ FREE TIER     │      │  PAID TIER    │
│               │      │               │
│ - Ollama      │      │ - Claude      │
│ - sentence-   │      │ - OpenAI      │
│   transformers│      │ - Gemini      │
│ - LLaVA       │      │               │
└───────────────┘      └───────────────┘
```

---

## 📦 FILE STRUCTURE

```
backend/
├── services/
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── base.py                    # Abstract interfaces
│   │   ├── factory.py                 # Provider factory
│   │   ├── config.py                  # AI provider configuration
│   │   │
│   │   ├── llm/
│   │   │   ├── __init__.py
│   │   │   ├── ollama_provider.py     # FREE
│   │   │   ├── claude_provider.py     # PAID
│   │   │   └── openai_provider.py     # PAID
│   │   │
│   │   ├── embedding/
│   │   │   ├── __init__.py
│   │   │   ├── local_provider.py      # FREE (sentence-transformers)
│   │   │   └── openai_provider.py     # PAID
│   │   │
│   │   └── vision/
│   │       ├── __init__.py
│   │       ├── llava_provider.py      # FREE
│   │       └── claude_provider.py     # PAID
│   │
│   ├── guard_chat.py                  # Uses LLMProvider
│   ├── instruction_parser.py          # Uses LLMProvider
│   └── video_summarizer.py            # Uses VisionProvider
```

---

## 🔧 IMPLEMENTATION

### 1. Base Abstractions (`backend/services/ai/base.py`)

```python
"""
Abstract base classes for all AI providers
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from dataclasses import dataclass
from enum import Enum


# ============================================================================
# DATA MODELS
# ============================================================================

@dataclass
class LLMMessage:
    """Standard message format for all LLM providers"""
    role: str  # 'user', 'assistant', 'system'
    content: str


@dataclass
class LLMResponse:
    """Standard response from LLM providers"""
    content: str
    model: str
    tokens_used: Optional[int] = None
    cost_usd: Optional[float] = None


@dataclass
class EmbeddingResponse:
    """Standard response from embedding providers"""
    embedding: List[float]
    model: str
    dimension: int
    cost_usd: Optional[float] = None


@dataclass
class VisionResponse:
    """Standard response from vision providers"""
    description: str
    model: str
    cost_usd: Optional[float] = None


class ProviderTier(Enum):
    """Provider pricing tier"""
    FREE = "free"
    PAID = "paid"


# ============================================================================
# ABSTRACT INTERFACES
# ============================================================================

class LLMProvider(ABC):
    """
    Abstract interface for Large Language Model providers

    Implementations:
    - OllamaProvider (FREE)
    - ClaudeProvider (PAID)
    - OpenAIProvider (PAID)
    """

    @abstractmethod
    async def chat(
        self,
        messages: List[LLMMessage],
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """
        Send messages to LLM and get response

        Args:
            messages: Conversation history
            system_prompt: System instruction
            temperature: Response randomness (0.0-1.0)
            max_tokens: Maximum response length

        Returns:
            LLMResponse with generated text
        """
        pass

    @abstractmethod
    async def generate(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """
        Simple text generation (single prompt)

        Args:
            prompt: User prompt
            system_prompt: System instruction
            temperature: Response randomness
            max_tokens: Maximum response length

        Returns:
            LLMResponse with generated text
        """
        pass

    @abstractmethod
    def get_tier(self) -> ProviderTier:
        """Return pricing tier (free/paid)"""
        pass

    @abstractmethod
    def get_name(self) -> str:
        """Return provider name"""
        pass


class EmbeddingProvider(ABC):
    """
    Abstract interface for text embedding providers

    Implementations:
    - LocalEmbeddingProvider (FREE - sentence-transformers)
    - OpenAIEmbeddingProvider (PAID)
    """

    @abstractmethod
    async def embed_text(self, text: str) -> EmbeddingResponse:
        """
        Generate embedding vector for text

        Args:
            text: Input text to embed

        Returns:
            EmbeddingResponse with vector
        """
        pass

    @abstractmethod
    async def embed_batch(self, texts: List[str]) -> List[EmbeddingResponse]:
        """
        Generate embeddings for multiple texts

        Args:
            texts: List of input texts

        Returns:
            List of EmbeddingResponse objects
        """
        pass

    @abstractmethod
    def get_dimension(self) -> int:
        """Return embedding dimension size"""
        pass

    @abstractmethod
    def get_tier(self) -> ProviderTier:
        """Return pricing tier (free/paid)"""
        pass

    @abstractmethod
    def get_name(self) -> str:
        """Return provider name"""
        pass


class VisionProvider(ABC):
    """
    Abstract interface for vision/multimodal providers

    Implementations:
    - LLaVAProvider (FREE - local)
    - ClaudeVisionProvider (PAID)
    """

    @abstractmethod
    async def analyze_image(
        self,
        image_data: bytes,
        prompt: str,
        max_tokens: int = 2048
    ) -> VisionResponse:
        """
        Analyze single image with prompt

        Args:
            image_data: Image bytes (JPEG/PNG)
            prompt: Question or instruction about image
            max_tokens: Maximum response length

        Returns:
            VisionResponse with description
        """
        pass

    @abstractmethod
    async def analyze_images(
        self,
        images: List[bytes],
        prompt: str,
        max_tokens: int = 2048
    ) -> VisionResponse:
        """
        Analyze multiple images with prompt

        Args:
            images: List of image bytes
            prompt: Question or instruction about images
            max_tokens: Maximum response length

        Returns:
            VisionResponse with description
        """
        pass

    @abstractmethod
    def get_tier(self) -> ProviderTier:
        """Return pricing tier (free/paid)"""
        pass

    @abstractmethod
    def get_name(self) -> str:
        """Return provider name"""
        pass
```

---

### 2. Configuration (`backend/services/ai/config.py`)

```python
"""
AI Provider Configuration

Environment variables control which providers are used
"""
from pydantic_settings import BaseSettings
from typing import Literal


class AIConfig(BaseSettings):
    """AI provider configuration from environment"""

    # ========================================================================
    # LLM PROVIDER
    # ========================================================================
    LLM_PROVIDER: Literal["ollama", "claude", "openai"] = "ollama"

    # Ollama settings (FREE)
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "llama3.1:8b"

    # Claude settings (PAID)
    ANTHROPIC_API_KEY: str = ""
    CLAUDE_MODEL: str = "claude-3-5-sonnet-20241022"

    # OpenAI settings (PAID)
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4o"

    # ========================================================================
    # EMBEDDING PROVIDER
    # ========================================================================
    EMBEDDING_PROVIDER: Literal["local", "openai"] = "local"

    # Local embeddings (FREE)
    LOCAL_EMBEDDING_MODEL: str = "all-MiniLM-L6-v2"
    LOCAL_EMBEDDING_DEVICE: str = "cpu"  # or "cuda"

    # OpenAI embeddings (PAID)
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-3-small"

    # ========================================================================
    # VISION PROVIDER
    # ========================================================================
    VISION_PROVIDER: Literal["llava", "claude"] = "llava"

    # LLaVA settings (FREE)
    LLAVA_BASE_URL: str = "http://localhost:11434"
    LLAVA_MODEL: str = "llava:13b"

    # Claude Vision settings (PAID)
    # Uses ANTHROPIC_API_KEY and CLAUDE_MODEL from above

    # ========================================================================
    # GENERAL SETTINGS
    # ========================================================================
    AI_TIMEOUT_SECONDS: int = 60
    AI_MAX_RETRIES: int = 3
    AI_CACHE_ENABLED: bool = True
    AI_CACHE_TTL_SECONDS: int = 3600  # 1 hour

    class Config:
        env_file = ".env"
        case_sensitive = True


# Global configuration instance
ai_config = AIConfig()
```

---

### 3. FREE Provider: Ollama LLM (`backend/services/ai/llm/ollama_provider.py`)

```python
"""
Ollama LLM Provider (FREE - runs locally)

Setup:
1. Install Ollama: https://ollama.ai
2. Pull model: ollama pull llama3.1:8b
3. Start server: ollama serve
"""
import httpx
from typing import List, Optional
from ..base import LLMProvider, LLMMessage, LLMResponse, ProviderTier
from ..config import ai_config


class OllamaProvider(LLMProvider):
    """
    FREE LLM provider using Ollama (local)

    Pros:
    - Completely free
    - No API keys needed
    - Privacy (data stays local)
    - No rate limits

    Cons:
    - Requires GPU for good performance
    - Slower than cloud APIs
    - Quality depends on model size
    """

    def __init__(
        self,
        base_url: str = None,
        model: str = None
    ):
        self.base_url = base_url or ai_config.OLLAMA_BASE_URL
        self.model = model or ai_config.OLLAMA_MODEL
        self.client = httpx.AsyncClient(timeout=ai_config.AI_TIMEOUT_SECONDS)

    async def chat(
        self,
        messages: List[LLMMessage],
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """Send chat messages to Ollama"""

        # Convert to Ollama format
        ollama_messages = []

        if system_prompt:
            ollama_messages.append({
                "role": "system",
                "content": system_prompt
            })

        for msg in messages:
            ollama_messages.append({
                "role": msg.role,
                "content": msg.content
            })

        # Call Ollama API
        response = await self.client.post(
            f"{self.base_url}/api/chat",
            json={
                "model": self.model,
                "messages": ollama_messages,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens
                }
            }
        )
        response.raise_for_status()

        data = response.json()

        return LLMResponse(
            content=data["message"]["content"],
            model=self.model,
            tokens_used=None,  # Ollama doesn't return token counts
            cost_usd=0.0  # FREE!
        )

    async def generate(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """Simple text generation"""

        # Convert to chat format
        messages = [LLMMessage(role="user", content=prompt)]
        return await self.chat(messages, system_prompt, temperature, max_tokens)

    def get_tier(self) -> ProviderTier:
        return ProviderTier.FREE

    def get_name(self) -> str:
        return f"Ollama ({self.model})"

    async def close(self):
        """Cleanup"""
        await self.client.aclose()
```

---

### 4. PAID Provider: Claude LLM (`backend/services/ai/llm/claude_provider.py`)

```python
"""
Claude LLM Provider (PAID - Anthropic API)

Setup:
1. Get API key: https://console.anthropic.com
2. Set ANTHROPIC_API_KEY in .env
"""
from anthropic import AsyncAnthropic
from typing import List, Optional
from ..base import LLMProvider, LLMMessage, LLMResponse, ProviderTier
from ..config import ai_config


class ClaudeProvider(LLMProvider):
    """
    PAID LLM provider using Claude (Anthropic)

    Pros:
    - Highest quality responses
    - Fast API response times
    - Large context windows
    - Excellent for complex reasoning

    Cons:
    - Costs money per token
    - Requires API key
    - Rate limits apply
    """

    # Pricing (as of Dec 2024)
    PRICING = {
        "claude-3-5-sonnet-20241022": {
            "input": 0.003,   # per 1K tokens
            "output": 0.015   # per 1K tokens
        },
        "claude-3-haiku-20240307": {
            "input": 0.00025,
            "output": 0.00125
        }
    }

    def __init__(
        self,
        api_key: str = None,
        model: str = None
    ):
        self.api_key = api_key or ai_config.ANTHROPIC_API_KEY
        self.model = model or ai_config.CLAUDE_MODEL

        if not self.api_key:
            raise ValueError("ANTHROPIC_API_KEY not set")

        self.client = AsyncAnthropic(api_key=self.api_key)

    async def chat(
        self,
        messages: List[LLMMessage],
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """Send chat messages to Claude"""

        # Convert to Anthropic format
        anthropic_messages = [
            {
                "role": msg.role,
                "content": msg.content
            }
            for msg in messages
        ]

        # Call Claude API
        response = await self.client.messages.create(
            model=self.model,
            max_tokens=max_tokens,
            temperature=temperature,
            system=system_prompt or "",
            messages=anthropic_messages
        )

        # Calculate cost
        pricing = self.PRICING.get(self.model, self.PRICING["claude-3-5-sonnet-20241022"])
        cost_usd = (
            (response.usage.input_tokens / 1000) * pricing["input"] +
            (response.usage.output_tokens / 1000) * pricing["output"]
        )

        return LLMResponse(
            content=response.content[0].text,
            model=self.model,
            tokens_used=response.usage.input_tokens + response.usage.output_tokens,
            cost_usd=cost_usd
        )

    async def generate(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> LLMResponse:
        """Simple text generation"""

        messages = [LLMMessage(role="user", content=prompt)]
        return await self.chat(messages, system_prompt, temperature, max_tokens)

    def get_tier(self) -> ProviderTier:
        return ProviderTier.PAID

    def get_name(self) -> str:
        return f"Claude ({self.model})"
```

---

### 5. FREE Provider: Local Embeddings (`backend/services/ai/embedding/local_provider.py`)

```python
"""
Local Embedding Provider (FREE - sentence-transformers)

Setup:
pip install sentence-transformers torch
"""
from sentence_transformers import SentenceTransformer
from typing import List
import torch
from ..base import EmbeddingProvider, EmbeddingResponse, ProviderTier
from ..config import ai_config


class LocalEmbeddingProvider(EmbeddingProvider):
    """
    FREE embedding provider using sentence-transformers

    Pros:
    - Completely free
    - Fast for batch processing
    - Privacy (data stays local)
    - No API keys needed

    Cons:
    - Requires model download (100-500MB)
    - Needs CPU/GPU resources
    - Quality slightly lower than OpenAI
    """

    def __init__(
        self,
        model_name: str = None,
        device: str = None
    ):
        self.model_name = model_name or ai_config.LOCAL_EMBEDDING_MODEL
        self.device = device or ai_config.LOCAL_EMBEDDING_DEVICE

        # Load model
        self.model = SentenceTransformer(self.model_name)
        self.model.to(self.device)

        self.dimension = self.model.get_sentence_embedding_dimension()

    async def embed_text(self, text: str) -> EmbeddingResponse:
        """Generate embedding for single text"""

        # Encode (runs synchronously, but fast)
        embedding = self.model.encode(
            text,
            convert_to_tensor=True,
            device=self.device
        )

        # Convert to list
        embedding_list = embedding.cpu().tolist()

        return EmbeddingResponse(
            embedding=embedding_list,
            model=self.model_name,
            dimension=self.dimension,
            cost_usd=0.0  # FREE!
        )

    async def embed_batch(self, texts: List[str]) -> List[EmbeddingResponse]:
        """Generate embeddings for multiple texts"""

        # Batch encode (much faster)
        embeddings = self.model.encode(
            texts,
            convert_to_tensor=True,
            device=self.device,
            batch_size=32
        )

        # Convert to list of responses
        responses = []
        for embedding in embeddings:
            responses.append(
                EmbeddingResponse(
                    embedding=embedding.cpu().tolist(),
                    model=self.model_name,
                    dimension=self.dimension,
                    cost_usd=0.0
                )
            )

        return responses

    def get_dimension(self) -> int:
        return self.dimension

    def get_tier(self) -> ProviderTier:
        return ProviderTier.FREE

    def get_name(self) -> str:
        return f"Local ({self.model_name})"
```

---

### 6. PAID Provider: OpenAI Embeddings (`backend/services/ai/embedding/openai_provider.py`)

```python
"""
OpenAI Embedding Provider (PAID)

Setup:
1. Get API key: https://platform.openai.com
2. Set OPENAI_API_KEY in .env
"""
from openai import AsyncOpenAI
from typing import List
from ..base import EmbeddingProvider, EmbeddingResponse, ProviderTier
from ..config import ai_config


class OpenAIEmbeddingProvider(EmbeddingProvider):
    """
    PAID embedding provider using OpenAI

    Pros:
    - Highest quality embeddings
    - Fast API response
    - Small model size
    - Great for search/RAG

    Cons:
    - Costs money per token
    - Requires API key
    """

    # Pricing (as of Dec 2024)
    PRICING = {
        "text-embedding-3-small": 0.00002,   # per 1K tokens
        "text-embedding-3-large": 0.00013
    }

    DIMENSIONS = {
        "text-embedding-3-small": 1536,
        "text-embedding-3-large": 3072
    }

    def __init__(
        self,
        api_key: str = None,
        model: str = None
    ):
        self.api_key = api_key or ai_config.OPENAI_API_KEY
        self.model = model or ai_config.OPENAI_EMBEDDING_MODEL

        if not self.api_key:
            raise ValueError("OPENAI_API_KEY not set")

        self.client = AsyncOpenAI(api_key=self.api_key)
        self.dimension = self.DIMENSIONS.get(self.model, 1536)

    async def embed_text(self, text: str) -> EmbeddingResponse:
        """Generate embedding for single text"""

        response = await self.client.embeddings.create(
            model=self.model,
            input=text
        )

        # Calculate cost
        pricing = self.PRICING.get(self.model, self.PRICING["text-embedding-3-small"])
        cost_usd = (response.usage.total_tokens / 1000) * pricing

        return EmbeddingResponse(
            embedding=response.data[0].embedding,
            model=self.model,
            dimension=self.dimension,
            cost_usd=cost_usd
        )

    async def embed_batch(self, texts: List[str]) -> List[EmbeddingResponse]:
        """Generate embeddings for multiple texts"""

        response = await self.client.embeddings.create(
            model=self.model,
            input=texts
        )

        # Calculate cost per embedding
        pricing = self.PRICING.get(self.model, self.PRICING["text-embedding-3-small"])
        total_cost = (response.usage.total_tokens / 1000) * pricing
        cost_per_embedding = total_cost / len(texts)

        # Build responses
        responses = []
        for data in response.data:
            responses.append(
                EmbeddingResponse(
                    embedding=data.embedding,
                    model=self.model,
                    dimension=self.dimension,
                    cost_usd=cost_per_embedding
                )
            )

        return responses

    def get_dimension(self) -> int:
        return self.dimension

    def get_tier(self) -> ProviderTier:
        return ProviderTier.PAID

    def get_name(self) -> str:
        return f"OpenAI ({self.model})"
```

---

### 7. Provider Factory (`backend/services/ai/factory.py`)

```python
"""
AI Provider Factory

Creates the correct provider based on configuration
"""
from typing import Optional
from .base import LLMProvider, EmbeddingProvider, VisionProvider
from .config import ai_config


# ============================================================================
# LLM FACTORY
# ============================================================================

def create_llm_provider(provider_name: Optional[str] = None) -> LLMProvider:
    """
    Create LLM provider based on configuration

    Args:
        provider_name: Override config (ollama, claude, openai)

    Returns:
        LLMProvider instance
    """
    provider = provider_name or ai_config.LLM_PROVIDER

    if provider == "ollama":
        from .llm.ollama_provider import OllamaProvider
        return OllamaProvider()

    elif provider == "claude":
        from .llm.claude_provider import ClaudeProvider
        return ClaudeProvider()

    elif provider == "openai":
        from .llm.openai_provider import OpenAIProvider
        return OpenAIProvider()

    else:
        raise ValueError(f"Unknown LLM provider: {provider}")


# ============================================================================
# EMBEDDING FACTORY
# ============================================================================

def create_embedding_provider(provider_name: Optional[str] = None) -> EmbeddingProvider:
    """
    Create embedding provider based on configuration

    Args:
        provider_name: Override config (local, openai)

    Returns:
        EmbeddingProvider instance
    """
    provider = provider_name or ai_config.EMBEDDING_PROVIDER

    if provider == "local":
        from .embedding.local_provider import LocalEmbeddingProvider
        return LocalEmbeddingProvider()

    elif provider == "openai":
        from .embedding.openai_provider import OpenAIEmbeddingProvider
        return OpenAIEmbeddingProvider()

    else:
        raise ValueError(f"Unknown embedding provider: {provider}")


# ============================================================================
# VISION FACTORY
# ============================================================================

def create_vision_provider(provider_name: Optional[str] = None) -> VisionProvider:
    """
    Create vision provider based on configuration

    Args:
        provider_name: Override config (llava, claude)

    Returns:
        VisionProvider instance
    """
    provider = provider_name or ai_config.VISION_PROVIDER

    if provider == "llava":
        from .vision.llava_provider import LLaVAProvider
        return LLaVAProvider()

    elif provider == "claude":
        from .vision.claude_provider import ClaudeVisionProvider
        return ClaudeVisionProvider()

    else:
        raise ValueError(f"Unknown vision provider: {provider}")


# ============================================================================
# SINGLETON INSTANCES (Optional - for dependency injection)
# ============================================================================

_llm_provider: Optional[LLMProvider] = None
_embedding_provider: Optional[EmbeddingProvider] = None
_vision_provider: Optional[VisionProvider] = None


def get_llm_provider() -> LLMProvider:
    """Get singleton LLM provider"""
    global _llm_provider
    if _llm_provider is None:
        _llm_provider = create_llm_provider()
    return _llm_provider


def get_embedding_provider() -> EmbeddingProvider:
    """Get singleton embedding provider"""
    global _embedding_provider
    if _embedding_provider is None:
        _embedding_provider = create_embedding_provider()
    return _embedding_provider


def get_vision_provider() -> VisionProvider:
    """Get singleton vision provider"""
    global _vision_provider
    if _vision_provider is None:
        _vision_provider = create_vision_provider()
    return _vision_provider
```

---

### 8. Updated Guard Chat (`backend/services/guard_chat.py`)

```python
"""
Guard Chat Service - Using Provider Abstraction

NOW SUPPORTS: Ollama (FREE) or Claude (PAID)
"""
from typing import List, Dict
from .ai.factory import get_llm_provider
from .ai.base import LLMMessage
from ai_worker.agent.guard_memory import GuardMemory


async def chat_with_guard(
    guard_id: str,
    user_message: str,
    conversation_history: List[Dict] = []
) -> str:
    """
    Chat with a guard using RAG over its memory

    Works with ANY LLM provider (Ollama or Claude)
    """

    # Step 1: Get LLM provider (from config)
    llm = get_llm_provider()

    # Step 2: Retrieve relevant events from guard's memory
    memory = GuardMemory(guard_id)
    relevant_events = await memory.search_memory(user_message, limit=10)

    # Step 3: Get guard configuration
    guard = await get_guard(guard_id)

    # Step 4: Build system prompt
    system_prompt = f"""You are {guard.name}, an AI security guard.

Your purpose: {guard.description}

Your capabilities: {', '.join(guard.skills)}

Your recent observations (last 24 hours):
{format_events_for_context(relevant_events)}

Respond naturally, helpfully, and professionally. Cite specific observations with timestamps when relevant."""

    # Step 5: Convert conversation to standard format
    messages = []
    for msg in conversation_history:
        messages.append(
            LLMMessage(
                role=msg["role"],
                content=msg["content"]
            )
        )

    # Add current user message
    messages.append(
        LLMMessage(role="user", content=user_message)
    )

    # Step 6: Call LLM (provider-agnostic!)
    response = await llm.chat(
        messages=messages,
        system_prompt=system_prompt,
        temperature=0.7,
        max_tokens=1024
    )

    # Log cost if paid tier
    if response.cost_usd and response.cost_usd > 0:
        print(f"[COST] Guard chat: ${response.cost_usd:.4f} ({llm.get_name()})")

    return response.content


def format_events_for_context(events: List[Dict]) -> str:
    """Format events for LLM context"""
    formatted = []
    for event in events:
        evt = event['event']
        formatted.append(
            f"- {evt['timestamp']}: {evt['event_type']} "
            f"(confidence: {evt['confidence']*100:.0f}%) - "
            f"{event['description']}"
        )
    return '\n'.join(formatted)
```

---

### 9. Updated Instruction Parser (`backend/services/instruction_parser.py`)

```python
"""
Instruction Parser Service - Using Provider Abstraction

NOW SUPPORTS: Ollama (FREE) or Claude (PAID)
"""
import yaml
from typing import Dict
from .ai.factory import get_llm_provider


async def parse_guard_instructions(user_input: str) -> dict:
    """
    Use LLM to convert natural language → structured rules

    Works with ANY LLM provider
    """

    # Get LLM provider
    llm = get_llm_provider()

    system_prompt = """You are a guard rule compiler for an AI CCTV system.

Convert user instructions into YAML guard rules.

Available events:
- person_detected, person_drinking, person_loitering, vehicle_detected,
  package_detected, zone_intrusion, unattended_object

Available zones:
- front_door, back_door, server_rack, pool_area, parking_lot

Available actions:
- alert, record_clip, notify, track_object

Output ONLY valid YAML following this schema:
```yaml
guard_rule:
  name: string
  when:
    event: string
    conditions:
      spatial: {zone: string, proximity: within|outside}
      temporal: {time_range: {start: HH:MM, end: HH:MM}, days_of_week: [int]}
      confidence: {min: float}
  then:
    actions:
      - type: string
        parameters: dict
```

Be precise. Map natural language to exact event types and zones."""

    prompt = f"Convert this instruction to a guard rule:\n\n{user_input}"

    # Call LLM (provider-agnostic!)
    response = await llm.generate(
        prompt=prompt,
        system_prompt=system_prompt,
        temperature=0.3,  # Lower temp for structured output
        max_tokens=1024
    )

    # Log cost if paid tier
    if response.cost_usd and response.cost_usd > 0:
        print(f"[COST] Rule parsing: ${response.cost_usd:.4f} ({llm.get_name()})")

    # Extract YAML from response
    yaml_text = response.content
    rule = yaml.safe_load(yaml_text)

    # Validate rule structure
    validate_rule_schema(rule)

    return rule


def validate_rule_schema(rule: dict):
    """Validate rule has required fields"""
    required = ['guard_rule']
    assert all(k in rule for k in required), "Invalid rule structure"

    rule_def = rule['guard_rule']
    assert 'name' in rule_def, "Rule must have a name"
    assert 'when' in rule_def, "Rule must have 'when' condition"
    assert 'then' in rule_def, "Rule must have 'then' actions"
```

---

### 10. Environment Configuration (`.env.example`)

```bash
# ============================================================================
# AI PROVIDER CONFIGURATION
# ============================================================================

# ----------------------------------------------------------------------------
# LLM Provider Selection
# ----------------------------------------------------------------------------
# Options: "ollama" (FREE), "claude" (PAID), "openai" (PAID)
LLM_PROVIDER=ollama

# Ollama Settings (FREE - Local)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b

# Claude Settings (PAID - Anthropic)
ANTHROPIC_API_KEY=your_api_key_here
CLAUDE_MODEL=claude-3-5-sonnet-20241022

# OpenAI Settings (PAID)
OPENAI_API_KEY=your_api_key_here
OPENAI_MODEL=gpt-4o

# ----------------------------------------------------------------------------
# Embedding Provider Selection
# ----------------------------------------------------------------------------
# Options: "local" (FREE), "openai" (PAID)
EMBEDDING_PROVIDER=local

# Local Embeddings (FREE - sentence-transformers)
LOCAL_EMBEDDING_MODEL=all-MiniLM-L6-v2
LOCAL_EMBEDDING_DEVICE=cpu

# OpenAI Embeddings (PAID)
OPENAI_EMBEDDING_MODEL=text-embedding-3-small

# ----------------------------------------------------------------------------
# Vision Provider Selection
# ----------------------------------------------------------------------------
# Options: "llava" (FREE), "claude" (PAID)
VISION_PROVIDER=llava

# LLaVA Settings (FREE - Local)
LLAVA_BASE_URL=http://localhost:11434
LLAVA_MODEL=llava:13b

# ----------------------------------------------------------------------------
# General AI Settings
# ----------------------------------------------------------------------------
AI_TIMEOUT_SECONDS=60
AI_MAX_RETRIES=3
AI_CACHE_ENABLED=true
AI_CACHE_TTL_SECONDS=3600
```

---

## 🚀 MIGRATION PATHS

### Scenario 1: Start FREE → Upgrade to PAID Later

**Initial Setup (Day 1):**
```bash
# .env
LLM_PROVIDER=ollama
EMBEDDING_PROVIDER=local
VISION_PROVIDER=llava
```

**After 1000 users (Month 3):**
```bash
# .env
LLM_PROVIDER=claude        # Upgrade for better quality
EMBEDDING_PROVIDER=openai   # Upgrade for better search
VISION_PROVIDER=claude      # Upgrade for better summaries
ANTHROPIC_API_KEY=sk-ant-xxx
OPENAI_API_KEY=sk-xxx
```

**NO CODE CHANGES NEEDED!**

---

### Scenario 2: Hybrid Approach (Optimize Costs)

```bash
# .env
LLM_PROVIDER=ollama         # FREE for simple tasks
EMBEDDING_PROVIDER=local    # FREE for RAG
VISION_PROVIDER=claude      # PAID only for critical summaries
```

**Code Example:**
```python
# Use FREE for guard chat
llm_free = create_llm_provider("ollama")
await llm_free.chat(messages)

# Use PAID for critical rule parsing
llm_paid = create_llm_provider("claude")
await llm_paid.generate(critical_prompt)
```

---

### Scenario 3: A/B Testing Providers

```python
# Test quality differences
import random

async def parse_with_ab_test(prompt: str):
    """Test Ollama vs Claude quality"""

    provider = random.choice(["ollama", "claude"])
    llm = create_llm_provider(provider)

    response = await llm.generate(prompt)

    # Log for comparison
    log_ab_test_result(provider, response, prompt)

    return response
```

---

## 📊 COST COMPARISON

### Monthly Cost for 1000 Active Guards

| Component | FREE (Ollama + Local) | PAID (Claude + OpenAI) | Hybrid |
|-----------|----------------------|------------------------|--------|
| **LLM Calls** | | | |
| Guard Creation (10/day) | $0 | $15 | $0 |
| Guard Chat (100/day) | $0 | $45 | $0 |
| Rule Parsing (10/day) | $0 | $15 | $15 |
| **Embeddings** | | | |
| Event Storage (1K/day) | $0 | $6 | $0 |
| RAG Queries (200/day) | $0 | $12 | $0 |
| **Vision** | | | |
| Summaries (10/day) | $0 | $90 | $90 |
| **Infrastructure** | | | |
| GPU (T4 for Ollama/LLaVA) | $120 | $0 | $120 |
| **TOTAL** | **$120/mo** | **$183/mo** | **$225/mo** |

**Recommendation for MVP:** Start with FREE ($120/mo for GPU), then hybrid ($225/mo) after product-market fit.

---

## ✅ IMPLEMENTATION CHECKLIST

### Week 1: Foundation
- [ ] Create `backend/services/ai/` directory structure
- [ ] Implement `base.py` (abstract interfaces)
- [ ] Implement `config.py` (environment config)
- [ ] Implement `factory.py` (provider factory)
- [ ] Create `.env.example` template

### Week 2: FREE Providers
- [ ] Implement `ollama_provider.py` (LLM)
- [ ] Implement `local_provider.py` (embeddings)
- [ ] Implement `llava_provider.py` (vision)
- [ ] Test with Ollama locally
- [ ] Write unit tests

### Week 3: PAID Providers
- [ ] Implement `claude_provider.py` (LLM)
- [ ] Implement `openai_provider.py` (embeddings)
- [ ] Implement `claude_provider.py` (vision)
- [ ] Test with real API keys
- [ ] Add cost tracking

### Week 4: Integration
- [ ] Update `guard_chat.py` to use factory
- [ ] Update `instruction_parser.py` to use factory
- [ ] Update `video_summarizer.py` to use factory
- [ ] Update `guard_memory.py` to use embedding provider
- [ ] Integration tests

### Week 5: Deployment
- [ ] Docker setup for Ollama
- [ ] Environment-based deployment configs
- [ ] Monitoring and cost tracking
- [ ] Documentation for team

---

## 🎯 FINAL NOTES

**Key Principles:**
1. **Application code NEVER imports specific providers directly**
2. **Always use factory pattern or dependency injection**
3. **All providers implement the same interface**
4. **Environment variables control which provider is used**

**This allows you to:**
- Start development with FREE local models
- Switch to PAID APIs when you have revenue
- A/B test different providers
- Optimize costs per use-case
- Never rewrite application logic

**You're ready to build ORIN with flexible AI providers!** 🚀
