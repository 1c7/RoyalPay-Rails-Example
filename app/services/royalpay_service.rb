module RoyalPay
  module_function
  
  # 这里有3个方法可用：
  # RoyalPay::create_qr_code_payment()  创建二维码支付订单，返回的数据里包含了二维码，可直接放到 <img> 中使用
  # RoyalPay::sign()                    发请求时构造签名
  # RoyalPay::verify_sign()             收到 RoyalPay notify_url 的 POST 请求时，验证签名

  # 创建QRCode支付单
  # https://mpay.royalpay.com.au/docs/cn/#api-QRCode-NewQRCode
  def create_qr_code_payment(out_trade_no, total_fee, description, notify_url, channel)
    # out_trade_no 商户订单号（我们自己的）
    # total_fee    要支付多少钱， 单位 '分'
    # description  订单标题
    # channel 	   支付渠道，大小写敏感，允许值: Alipay, Wechat

    royalpay_partner_code = 'XXXX'
    royalpay_credential_code = 'AAAAI2M5hVSbBBBBpncrRZjjvZWEZZZZ'
    
    base_URL = "https://mpay.royalpay.com.au/api/v1.0/gateway/partners/#{royalpay_partner_code}/orders/#{out_trade_no}"
    # 支付所需参数
    payload = {
      description: description,
      price: total_fee,
      currency: 'AUD',  # Allowed values: AUD, CNY
      channel: channel, # Allowed values: Alipay, Wechat
      notify_url: notify_url,
    }
    # 生成签名
    time = DateTime.now.strftime('%Q') 
    nonce_str = SecureRandom.uuid.tr('-', '') # 长度 32 位
    sign = sign(time, nonce_str, royalpay_partner_code, royalpay_credential_code)
    
    # 把必要参数拼到 URL 里
    params = {
      time: time,
      nonce_str: nonce_str,
      sign: sign
    }
    final_URL = base_URL + "?" + params.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join('&')

    # 发请求
    http_return = RestClient.put(final_URL, payload.to_json, content_type: :json)
    result = http_return.body
    json = JSON.parse(result)
    return json
  end
  
  # 生成 RoyalPay 签名
  # 具体签名步骤文档里有：https://mpay.royalpay.com.au/docs/cn
  def sign(time, nonce_str, royalpay_partner_code, royalpay_credential_code)
    # time:                     当前UTC时间的毫秒数时间戳，例子：1521620326883
    # nonce_str:                随机字符串
    # royalpay_partner_code:    商户编码，由4位大写字母或数字构成
    # royalpay_credential_code: 系统为商户分配的开发校验码
    valid_string = "#{royalpay_partner_code}&#{time}&#{nonce_str}&#{royalpay_credential_code}"
    sign = Digest::hexencode(Digest::SHA256.digest(valid_string)).downcase
    return sign
    # example: 8e08ce01f520761df90477f0887672a62ee9b145aec03fa35dc0954ff11950bb
  end
  
  # 验证签名是否正确, 用于 RoyalPay 支付成功时的回调
  # 返回 true / false
  def verify_sign(time, nonce_str, sign)
    # 验证签名的思路：
    # 之前我们发请求给 RoyalPay 创建订单时，签名用上了：
    # time, nonce_str, partner_code, credential_code
    # 这 4 项
    #
    # 当 RoyalPay 给我们发请求时，传递了 time, nonce_str 和 sign
    #
    # 现在思路就很清晰了
    # 把 RoyalPay 给的 time 和 nonce_str，加上我们的 partner_code 和 credential_code
    # 运算得到一个 sign
    # 拿运算出来的 sign，对比传递过来的 sign
    # 如果一致，就是对的。
    # 因为只有我们和 RoyalPay，知道 Parter Code 和 Credential Code
    # 其他人如果试图伪造，sign 会不一致
    # ====
    
    royalpay_partner_code = 'XXXX'
    royalpay_credential_code = 'AAAAI2M5hVSbBBBBpncrRZjjvZWEZZZZ'
    
    calculate_sign = sign(time, nonce_str, royalpay_partner_code, royalpay_credential_code)
    if calculate_sign == sign
      return true
    else
      return false 
    end
    # 计算并对比，返回是否有效 true | false
  end

end