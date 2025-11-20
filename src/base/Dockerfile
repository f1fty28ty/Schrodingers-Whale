FROM docker:dind

# Fragment 2: Plain base64 in label (Medium)
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 3: SHA256 encrypted fragment (Hard - needs key from logs)
# This is "  state-dead:\n    image: f1fty28ty/schrodingers-whale:dead" XORed with SHA256("quantum_observer_2025")
LABEL quantum.encrypted.fragment="8bd7cc8b811ee0d41ebbba352c7929b02e55c37b6fd26e096701ea3d3bf9e6c48bd3d789bf37f4d10982e36e137d56a13800c46544a37d1e643bbf3902a5fe86a6a6e699871ef3d21eafdd362c6f52e6"

# Fragment 5: Copy then delete - will be in layer (Very Hard)
COPY fragments/state_dead.yml /tmp/.quantum_state_dead
RUN rm /tmp/.quantum_state_dead

# Hint for Fragment 5
LABEL quantum.fragment.5.hint="Fragment 5 exists in a deleted layer. Use 'dive' to find the layer containing 'quantum_state_dead' and note its SHA digest. Then use 'docker save' to extract that specific layer."

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]