FROM docker:dind

# Fragment 2: Easy to find label
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 4: In build history (visible in docker history)
LABEL quantum.fragment.4="ICBzdGF0ZS1kZWFkOgogICAgaW1hZ2U6IGYxZnR5Mjh0eS9zY2hyb2RpbmdlcnMtd2hhbGU6ZGVhZA=="

# Fragment 3: In environment variable (need --format to see easily)
ENV QUANTUM_FRAGMENT_3="ICAgIGxhYmVsczoKICAgICAgLSBxdWFudHVtLmVudGFuZ2xlZD10cnVl"

# Fragment 5: Hidden in different namespace - harder to find
# Not in the obvious "quantum.fragment.*" pattern
LABEL org.opencontainers.image.state.dead="ZW52aXJvbm1lbnQ6CiAgICAgIC0gUVVBTlRVTV9TVEFURT1ERUFECiAgICBwcm9maWxlczoKICAgICAgLSBjb2xsYXBzZWQKICAgIGxhYmVsczoKICAgICAgLSBxdWFudHVtLmVudGFuZ2xlZD10cnVl"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]