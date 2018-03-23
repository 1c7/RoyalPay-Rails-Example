class TestController < ApplicationController
  require 'rest-client'
  require 'json'
  require 'royalpay_service'
  
  def index
    ######### SECRET ##########
    # 请填入 RoyalPay 的 partner code 和 credential code 到这里
    royalpay_partner_code = ''
    royalpay_credential_code = ''
    ######### SECRET ##########
    
    order_id = 'testonly5678-1' # 商户订单号
    base_URL = "https://mpay.royalpay.com.au/api/v1.0/gateway/partners/#{royalpay_partner_code}/orders/#{order_id}"
    
    # 支付所需参数（会以 JSON 格式发送过去）
    payload = {
      description: 'haha',
      price: 1,          # 1分
      currency: 'AUD',   # 澳元
      channel: 'Wechat', # 微信
    }
    
    # 生成签名
    time = DateTime.now.strftime('%Q') 
    nonce_str = SecureRandom.uuid.tr('-', '') # 长度 32 位
    sign = RoyalPay::sign(time, nonce_str, royalpay_partner_code, royalpay_credential_code)
    
    # 把签名拼到 URL 里（文档要求这么做的）
    params = {
      time: time,
      nonce_str: nonce_str,
      sign: sign
    }
    final_URL = base_URL + "?" + params.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join('&')

    # 发请求
    http_return = RestClient.put(final_URL, payload.to_json, content_type: :json)
    
    result = http_return.body
    j = JSON.parse(result)
    # 返回示例：
    # {
    # "partner_order_id": "testonly5678",
    # "full_name": "XXXX INTERNATIONAL TRADING PTY LTD",
    # "code_url": "https://mpay.royalpay.com.au/api/v1.0/payment/partners/XXXX/orders/0404020180321191303653XXXX/retail_pay",
    # "partner_name": "XXXX",
    # "channel": "Wechat",
    # "result_code": "EXISTS",
    # "partner_code": "XXXX",
    # "order_id": "04040201803211913036538217",
    # "return_code": "SUCCESS",
    # "pay_url": "https://mpay.royalpay.com.au/api/v1.0/gateway/partners/XXXX/orders/testonly5678/pay",
    # "qrcode_img": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsAQAAAABRBrPYAAACE0lEQVR42u2aS47DIBBE2yuOwU1tfFOOMEuvYKhqcGInI83WJSwrwvBWTdE/YvU/z49NbGITm9jEFLBieLY2CLn97u09Yq0Zs0ELwzivjTl8Pq8A8taXlLD8NtlgWGMhvCpibXI5YsISLLPpYs0Oe6XIOViDJObCftvxZpz6x1l4NEbHBQtc36/+7dFYfw6Qy/DM+18x68lYoUM2i8VwnBf6rmSRalfDmssqQ9j7YZR65EAKq1yip4op9COc6KjXoIUdWE08wi0GwThd7ZetF8AK5G0ItSPs+r7fg5EAFhBqC5eayJNrHr4rX86CBFZGPpw8e+Qndj9IYZ4S0wI0Ak8xxRCLGMZkeOFBTi7sVgt8iFwAo7zhu2r13YdZPFu+xiwFzPOK1UbJM+Brbvl4rFcBqF6xxCqgugaKFgaDeNo/opKdM3LYPpIK3/SWG38JRgIYPFXPhF/ByDy/ksLojSFyt8mo3Gu6nYXnY0PkKOhSzx6NwTebGNb7h6fIaZZQ72WsAtZzDLaFz7Sq13piGPRsLnIv2PFZP/pvz8cQd14JhvfZxk2HEuaPt2JYvA+vRZsoYWVYYB1mcSutt5glgPVbG55oNks3JsYlfOmTPxzj9Q3dF9R+dIV7CS+J+fUNmzCeJJsoxr53OEWOTkUKYth5UVV5Y+735pHhSQs7L6o48BrWG6emhc2/uExsYhObmD72C5insIKPLkB/AAAAAElFTkSuQmCC"
    # }

    @qr_code = j['qrcode_img']
  end
end

