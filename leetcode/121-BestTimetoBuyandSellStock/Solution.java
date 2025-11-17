/***生词
 *stock股票，库存
 *profit利润
 *achieve实现
 *transaction交易
 *
 *
 *
***/
class Solution {
    public int maxProfit(int[] prices) {
        int currentMaxProfit = 0;
       // prices = {7,1,5,3,6,4};
        for(int i=0;i<prices.length-1;i++){
            for(int j=i+1;j<prices.length;j++){
                if(prices[j]-prices[i]>currentMaxProfit){
                    currentMaxProfit = prices[j]-prices[i];
                }
            }
        }
        return currentMaxProfit;
    }
}
