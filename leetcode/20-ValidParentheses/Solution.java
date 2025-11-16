/***生词
 *parentheses括号
 *determine决定
 *brackets括号
 *correct正确的
 *corresponding相应的
 *consists由...组成
 *character字符
 *
 *
 *
 ***/
//s = "{}"
import java.util.Stack;
class Solution {
    public boolean isValid(String s) {
       Stack<Character> stack = new Stack<>();
       for(char c: s.toCharArray()){
           if(c==')' || c=='}' || c==']'){
               if(stack.isEmpty()){
                   return false;
               }
               char x = stack.pop();
               if(c == ')' && x != '('){
                   return false;
               }

               if(c == ']' && x != '['){
                   return false;
               }

               if(c == '}' && x != '{'){
                   return false;
               }
           }else{
               stack.push(c);
               
           }
       }
    
       return stack.isEmpty();
    }
}
