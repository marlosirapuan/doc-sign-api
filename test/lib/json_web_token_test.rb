require "test_helper"

class JsonWebTokenTest < ActiveSupport::TestCase
  test "should encode and decode a token correctly" do
    # Arrange
    payload = { user_id: 1 }

    # Act & Assert
    token = JsonWebToken.encode(payload)
    assert token.present?, "Token should be generated"

    # Act & Assert
    decoded = JsonWebToken.decode(token)
    assert decoded.present?, "Decoded token should not be nil"
    assert_equal payload[:user_id], decoded[:user_id]
  end

  test "should return nil for invalid token" do
    # Arrange
    invalid_token = "this.is.not.a.valid.token"

    # Act & Assert
    decoded = JsonWebToken.decode(invalid_token)
    assert_nil decoded, "Decoding an invalid token should return nil"
  end

  test "should expire token after time" do
    # Arrange
    payload = { user_id: 1 }
    expired_token = JsonWebToken.encode(payload, 1.second.from_now)

    sleep 1.5

    # Act & Assert
    decoded = JsonWebToken.decode(expired_token)
    assert_nil decoded, "Decoding an expired token should return nil"
  end
end
