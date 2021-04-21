const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list = [
  {
    'name': 'Laminar TC3',
    'ss58': 42,
    'endpoint': 'wss://node-6787234140909940736.jm.onfinality.io/ws',
  },
  {
    'name': 'Laminar TC3 Node 1',
    'ss58': 42,
    'endpoint': 'wss://testnet-node-1.laminar-chain.laminar.one/ws',
  },
];

const laminar_plugin_cache_key = 'plugin_laminar';

const laminar_token_decimals = 18;
const acala_stable_coin = 'AUSD';
const acala_stable_coin_view = 'aUSD';

const GraphQLConfig = {
  'httpUri': 'https://indexer.laminar-chain.laminar.one/v1/graphql',
  'wsUri': 'wss://indexer.laminar-chain.laminar.one/v1/graphql',
};
const Map<String, String> margin_pool_name_map = {
  '0': 'Laminar',
  '1': 'Crypto',
  '2': 'FX',
};
const Map<String, String> synthetic_pool_name_map = {
  '0': 'Laminar',
  '1': 'Crypto',
  '2': 'FX',
};
const Map<String, String> laminar_leverage_map = {
  'Two': 'x2',
  'Three': 'x3',
  'Five': 'x5',
  'Ten': 'x10',
  'Twenty': 'x20',
};
final BigInt laminarIntDivisor = BigInt.parse('1000000000000000000');

const laminar_genesis_hash =
    '0x0679c5a52887843b46cc6fa26e5fb9b6f0a4fa41ca1161c01eadacc4748cb203';
