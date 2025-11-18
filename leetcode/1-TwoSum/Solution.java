/***生词 
*indices索引
*add up to加起来等于
*assume假设 
*exactly确切的
*solution解决方案
*order顺序,命令
*constrains限制
*valid有效的
***/
class Solution {
    public int[] twoSum(int[] nums, int target) {
//        int[] nums = {2,7,11,15};
//        int target = 9;
//
//
        for(int i = 0; i < nums.length-1;i++){
            for(int j = i+1;j < nums.length;j++){
                if(nums[i]+nums[j]==target){
                    return new int[]{i,j};
                }
            }
        }
        return null;
    }
}
