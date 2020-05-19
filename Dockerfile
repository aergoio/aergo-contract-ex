FROM aergo/ship

WORKDIR /contracts
COPY . .
RUN ./scripts/publish.sh
