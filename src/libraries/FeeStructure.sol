// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract FeeStructure {
  uint256 constant log_10_2 =      301029995663981195213738;
  uint256 constant log_10_2_base_7prec = 100000000000000000;
  uint256 constant two_64 = 18446744073709551616;
  uint256 constant blocksPerYear = 2628000;
  uint256 constant baseFeeBps = 200;
  uint256 constant public maxLenderRateBpsPerBlock = 178000000;

  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  // function getFeeCutBpsByLenderRate(uint256 lenderRateBps) external pure returns (uint256) {
  //   uint256 clientRate = getClientRateByLenderRate(lenderRateBps);
  //   return (clientRate - lenderRateBps) * 10000 / clientRate;
  // }

  function getFeeCutBpsByLenderRatePerBlock(uint32 lenderRateBpsPerBlock) external pure returns (uint256) {
    if (lenderRateBpsPerBlock > maxLenderRateBpsPerBlock) return 0;
    if (lenderRateBpsPerBlock == 0) return 10000;
    uint256 lenderRateBps = lenderRateBpsPerBlock * blocksPerYear / 1000000;
    uint256 clientRate = getClientRateByLenderRate(lenderRateBps);
    return (clientRate - lenderRateBps) * 10000 / clientRate;
  }

  function getClientRateByLenderRatePerBlock(uint32 lenderRateBpsPerBlock) external pure returns (uint32) {
    if (lenderRateBpsPerBlock > maxLenderRateBpsPerBlock) return uint32(lenderRateBpsPerBlock);
    if (lenderRateBpsPerBlock == 0) return uint32(baseFeeBps*1000000/blocksPerYear);
    uint256 lenderRateBps = lenderRateBpsPerBlock * blocksPerYear / 1000000;
    uint256 clientRate = getClientRateByLenderRate(lenderRateBps);
    return uint32(clientRate*1000000/blocksPerYear);
  }

  function getClientRateByLenderRate(uint256 lenderRateBps) internal pure returns (uint256) {
    uint extraFee = (uint256(uint128(log_2(int128(int256(10000 + lenderRateBps))*int128(int256(two_64)))))  * log_10_2 / two_64 / log_10_2_base_7prec - 40000000) *10000 / 10000000 ;
    return lenderRateBps + extraFee + baseFeeBps;
  }

//   function getFeeCutBpsByClientRate(uint256 clientRateBps) external pure returns (uint256) {
//     require(clientRateBps >= baseFeeBps);
//     // log 1+lR = cR
//     uint lenderRate = 10**(clientRateBps - baseFeeBps) - 10000;
//     return (clientRateBps - lenderRate) / clientRateBps;
//     //uint extraFee = (uint256(uint128(log_2(int128(int256(10000 + lenderRateBps))*int128(int256(two_64)))))  * log_10_2 / two_64 / log_10_2_base_7prec - 40000000) *10000 / 10000000 ;
//     //return (extraFee + baseFeeBps) * 10000 / (lenderRateBps + extraFee + baseFeeBps);
//   }
}