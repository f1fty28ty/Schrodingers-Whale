FROM docker:dind

# Fragment 2: Plain base64 in label (Medium)
LABEL quantum.fragment.2="ICAgIGVudmlyb25tZW50OgogICAgICAtIFFVQU5UVU1fU1RBVEU9QUxJVkUKICAgIHByb2ZpbGVzOgogICAgICAtIGNvbGxhcHNlZA=="

# Fragment 3: SHA256 encrypted fragment (Hard - needs key from logs)
# This is "  state-dead:\n    image: f1fty28ty/schrodingers-whale:dead" XORed with SHA256("quantum_observer_2025")
LABEL quantum.encrypted.fragment="8bd7cf96ac1ede8c1d85dd2d155400902871ed7b6fd26e094a05992d059cf587a6dcd885a934f09120afcd2b2c1c17b73b769d2c45ff7902453f9a3202f8e19aa6d3db85bf1ef08c1eace4153f6d2ebc2875c0687fc64b02493f99382c9ce9c2a7c0c7c58111cd9227dac531154356b0006599727cc965144a0ebf3a389ccb9e8df9dc9dbc0ef7d9"

# Fragment 5: Copy then delete - will be in layer (Very Hard)
COPY fragments/state_dead.yml /tmp/.quantum_state_dead
RUN rm /tmp/.quantum_state_dead

# Hint for Fragment 5
LABEL quantum.fragment.5.hint="Fragment 5 exists in a deleted layer. Use 'dive' to find the layer containing 'quantum_state_dead' and note its SHA digest. Then use 'docker save' to extract that specific layer."

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]