module.exports = {
  minDeposit: Math.pow(10, 17),
  maxDeposit: Math.pow(10, 18),
  ticketTtlSeconds: 300,
  joinFeePercentage: 5,
  // 1-10 dollar min/max
  minFee: 0.001 * Math.pow(10,18),
  maxFee: 0.01 * Math.pow(10,18)
};