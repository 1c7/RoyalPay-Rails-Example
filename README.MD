## RoyalPay Ruby on Rails 参考例子

### Royalpay 是什么
一家支付商，更多介绍在：https://www.royalpay.com.au/   

### 这里的代码是什么
简单的几十行代码示例，如果你需要把 RoyalPay 整合到你的 Ruby on Rails 项目中，这里的代码能帮你节省不少时间   
（你就不用自己写，复制粘贴就行）
注意：这里只做了二维码支付。并不是全部都有。

### 如何使用
这里只有2个文件，都在 app/ 目录里，你看看就明白了 
`app/controllers/test_controller.rb`
`app/services/royalpay_service.rb`
因为代码就几十行，所以我就没有做成 gem, 实在没那个必要   

### 缘由
最近(2018年3月)做了 RoyalPay 的支付整合，   
是一个 Rails 4 的电商项目。    
这个项目只需要用到 RoyalPay 里的二维码扫码支付（微信和支付宝）
做完之后我想着把代码开源出来方便其他 Rails 程序员，所以有了这个库