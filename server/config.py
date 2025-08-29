from dotenv import load_dotenv
from pydantic_settings import BaseSettings, SettingsConfigDict

load_dotenv()


class Settings(BaseSettings):
    TAVILY_API_KEY: str = ""
    GEMINI_API_KEY: str = ""
    # Ensure .env is loaded even if python-dotenv doesn't run (reloader, different CWD, etc.)
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")
