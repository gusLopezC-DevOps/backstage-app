import {
  ScmIntegrationsApi,
  scmIntegrationsApiRef,
  ScmAuth,
} from '@backstage/integration-react';
import {
  AnyApiFactory,
  configApiRef,
  createApiFactory,
  discoveryApiRef,
  fetchApiRef,
  githubAuthApiRef,
} from '@backstage/core-plugin-api';
import {
  DoraMetricsClient,
  doraMetricsApiRef,
  MockDoraMetricsClient,
} from '@c2l2c/backstage-plugin-dora-metrics';
import { kyvernoApiRef, KyvernoApiClient } from './components/kyverno/api';

export const apis: AnyApiFactory[] = [
  createApiFactory({
    api: scmIntegrationsApiRef,
    deps: { configApi: configApiRef },
    factory: ({ configApi }) => ScmIntegrationsApi.fromConfig(configApi),
  }),
  ScmAuth.createDefaultApiFactory(),
  createApiFactory({
    api: kyvernoApiRef,
    deps: { discoveryApi: discoveryApiRef, fetchApi: fetchApiRef },
    factory: ({ discoveryApi, fetchApi }) => new KyvernoApiClient(discoveryApi, fetchApi),
  }),
  createApiFactory({
    api: doraMetricsApiRef,
    deps: { githubAuthApi: githubAuthApiRef, configApi: configApiRef },
    factory: ({ githubAuthApi, configApi }) =>
      configApi.getOptionalBoolean('app.doraMetrics.debug')
        ? new MockDoraMetricsClient()
        : new DoraMetricsClient(githubAuthApi, configApi),
  }),
];
