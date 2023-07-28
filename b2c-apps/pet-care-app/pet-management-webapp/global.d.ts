import 'vite/client'

interface ImportMeta {
    env: {
      VITE_MY_ENV_VARIABLE: string;
      VITE_BASE_URL: string;
      VITE_CLIENT_ID: string;
      VITE_SCOPE: string;
      VITE_SIGN_IN_REDIRECT_URL: string;
      VITE_SIGN_OUT_REDIRECT_URL: string;
      VITE_RESOURCE_SERVER_URL: string;
    }
  }