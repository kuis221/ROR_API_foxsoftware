class AuthenticationController < ApplicationController
  # this is stub controller created for documentation

  swagger_controller :authentication, 'Authenticating Fox LMP API'

  swagger_api :registration do
    summary 'This part explain how authentication should be make'
    notes <<-N
        <h2>Registration overall</h2>
        <p>
          User can have access in two ways, by email+password registration and by oauth registration(facebook, google, linkedin), so
          there are two endpoints for each way.
        </p>

        <h2>Authorization registered users</h2>
        <h3>Token Header Format</h2>

        <p>The authentication information should be included by the client in the headers or query params of <strong>EACH</strong> request. The headers follow the RFC 6750 Bearer Token format:</p>

        <p>Authentication headers example:</p>
        <pre><code class='ruby'>{
          "access-token": "wwwww",
          "client":       "xxxxx",
          "expiry":       "yyyyy",
          "uid":          "zzzzz"
        }</code></pre>

        <p>The authentication headers consists of the following params:</p>

        <table><thead>
          <tr>
          <th>param</th>
          <th>description</th>
          </tr>
          </thead><tbody>
          <tr>
          <td><strong><code>access-token</code></strong></td>
          <td>This serves as the user's password for each request. A hashed version of this value is stored in the database for later comparison. This value should be changed on each request.</td>
          </tr>
          <tr>
          <td><strong><code>client</code></strong></td>
          <td>This enables the use of multiple simultaneous sessions on different clients. (For example, a user may want to be authenticated on both their phone and their laptop at the same time.)</td>
          </tr>
          <tr>
          <td><strong><code>expiry</code></strong></td>
          <td>The date at which the current session will expire. This can be used by clients to invalidate expired tokens without the need for an API request.</td>
          </tr>
          <tr>
          <td><strong><code>uid</code></strong></td>
          <td>A unique value that is used to identify the user. This is necessary because searching the DB for users by their access token will make the API susceptible to <a href="http://codahale.com/a-lesson-in-timing-attacks/">timing attacks</a>.</td>
          </tr>
        </tbody></table>

        <p>The authentication headers required for each request will be available in the response from the previous request. If you are using the <a href="https://github.com/lynndylanhurley/ng-token-auth">ng-token-auth</a> AngularJS module or the <a href="https://github.com/lynndylanhurley/j-toker">jToker</a> jQuery plugin, this functionality is already provided.</p>
    N
  end
  def registration
    render json: {text: 'Nothing here, this was just created for auth documentation.'}
  end

  swagger_api :confirmation do
    summary 'Confirming user from email link'
    notes <<-N
      <p>When user clicks confirmation link in his email, he lands on <strong>/auth/confirmation</strong> with few params:
      <strong>confirmation_token</strong> and <strong>config</strong></p>
      You have to pass two those to the same endpoint in the API.<br/>
      <p>
        When the user confirmed successfully you will also receive authentication headers, just like in login procedure(see above example)
      </p>
    N
    param :query, :confirmation_token, :string, :required, 'Confirmation token'
    param :query, :config, :string, :required, 'Some config needed for API'
    response 'not_found', 'When we cant find that user'
    response 'ok', 'UserObject'
  end
  def confirmation
    render json: {text: 'Nothing here, this was just created for auth documentation.'}
  end

end
