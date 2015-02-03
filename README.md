# Jackal Code Fetcher

Fetch code from a repository and stash reference in the asset store.

## Configuration

The code fetcher uses the asset store to persist compressed code
asset. Configure:

```json
{
  "jackal": {
    "assets": {
      "provider": PROVIDER,
      "credentials": {
        CREDENTIALS
      }
    }
  }
}
```

## Supported Remotes

### GitHub

Access tokens are used for fetching private repositories. Token can
be provided via direct configuration:

```json
{
  "jackal": {
    "code_fetcher": {
      "config": {
        "github": {
          "access_token": TOKEN
        }
      }
    }
  }
}
```

or it can be provided via application level configuration:

```json
{
  "jackal": {
    "github": {
      "access_token": ACCESS_TOKEN
    }
  }
}
```

# Info

* Repository: https://github.com/carnivore-rb/jackal-code-fetcher
* IRC: Freenode @ #carnivore
