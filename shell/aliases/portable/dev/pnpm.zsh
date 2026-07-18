p() {
  pnpm -s "$@"
}

pri() {
  s rm -rf node_modules && s pnpm i
}
