import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "https://f703cfddc8a4b48d3ff710f8ad599f6f@o4507663085862912.ingest.de.sentry.io/4507663089074256",
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration({
      // Disable masking by default,
      // due to no financial transactions or sensitive information
      maskAllText: false,
      blockAllMedia: false,
    }),
    // The following is all you need to enable canvas recording with Replay
    // Experimental, as it risks slowing down game rendering
    Sentry.replayCanvasIntegration(),
  ],
  // Performance Monitoring
  tracesSampleRate: 1.0, //  Capture 100% of the transactions
  // Set 'tracePropagationTargets' to control for which URLs distributed tracing should be enabled
  tracePropagationTargets: [/^https:\/\/staging\.obsidiantears\.xyz/],
  // Session Replay
  replaysSessionSampleRate: 0.1, // This sets the sample rate at 10%. You may want to change it to 100% while in development and then sample at a lower rate in production.
  replaysOnErrorSampleRate: 1.0, // If you're not already sampling the entire session, change the sample rate to 100% when sampling sessions where errors occur.
});
