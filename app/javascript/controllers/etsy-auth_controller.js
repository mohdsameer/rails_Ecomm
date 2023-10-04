import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    code:  String,
    state: String
  }

  connect() {
    console.log("Etsy auth controller connected");

    const grant_type    = 'authorization_code'
    const code          = this.codeValue;
    const state         = this.stateValue;
    const client_id     = 'd2dltlxiqk49e004gugboek1';
    const redirect_uri  = 'https://1c42-122-161-50-131.ngrok-free.app/callbacks/etsy';
    const code_verifier = 'K94K6mcprGgXtQkCdjufR3IPVrSJBg60k-Memd8SYTHmsBI18efHhLMNT_06JBcYj6BEjX3le--XFBTQT7SjTz0PRJ2CJtspw5bjt6kIgQ5gOrWsAnV5yT0kp284b_QZ'

    let full_url = "https://api.etsy.com/v3/public/oauth/token?"

    full_url += `grant_type=${grant_type}`
    full_url += `&client_id=${client_id}`
    full_url += `&redirect_uri=${redirect_uri}`
    full_url += `&code=${code}`
    full_url += `&code_verifier=${code_verifier}`

    // fetch(`https://1c42-122-161-50-131.ngrok-free.app/callbacks/etsy_token?code=${code}&state=${state}`, {
    //   mode: "same-origin"
    // });

    const body_data = { grant_type: grant_type, client_id: client_id, redirect_uri: redirect_uri, code: code, code_verifier: code_verifier }

    // console.log('body_data', body_data);

    fetch(full_url, {
      method: "POST",
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    })
      .then(response => {
        console.log(response)
      })
  }
}
