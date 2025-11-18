FROM docker:dind

# Fragment 5: Copy then delete (stays in layer)
COPY fragments/state_dead.yml /tmp/.quantum_state_dead
RUN rm /tmp/.quantum_state_dead

# Fragment 2: In labels
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 4: In history (FIXED - includes Docker Hub username)
LABEL quantum.fragment.4="ICBzdGF0ZS1kZWFkOgogICAgaW1hZ2U6IGYxZnR5Mjh0eS9zY2hyb2RpbmdlcnMtd2hhbGU6ZGVhZA=="

# Fragment 3: In environment
ENV QUANTUM_FRAGMENT_3="ICAgIGxhYmVsczoKICAgICAgLSBxdWFudHVtLmVudGFuZ2xlZD10cnVl"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]