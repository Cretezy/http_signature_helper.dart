import 'package:http_signature_helper/http_signature_helper.dart';
import 'package:test/test.dart';

void main() {
  test('create signature string', () {
    final correct =
        "(request-target): get /foo\nhost: example.org\ndate: Tue, 07 Jun 2014 20:51:35 GMT\ncache-control: max-age=60, must-revalidate\nx-example: Example header with some whitespace.\nbody";

    final signatureString = SignatureString(
      body: "body",
      headers: {
        "Host": "example.org",
        "Date": "Tue, 07 Jun 2014 20:51:35 GMT",
        "X-Example": """Example header
    with some whitespace.""",
        "Cache-Control": "max-age=60, must-revalidate"
      },
      signatureHeaders: [
        "(request-target)",
        "host",
        "date",
        "cache-control",
        "x-example"
      ],
      target: SignatureTarget("GET", "/foo"),
    );

    expect(signatureString.toString(), correct);
  });

  test("creates signature header", () {
    final correct =
        'Signature keyId="rsa-key-1",algorithm="rsa-sha256",headers="(request-target) host date digest content-length",signature="rsa-signature-1"';
    final signatureHeader = SignatureHeader(
      keyId: "rsa-key-1",
      algorithm: "rsa-sha256",
      signatureHeaders: [
        "(request-target)",
        "host",
        "date",
        "digest",
        "content-length"
      ],
      signature: "rsa-signature-1",
    );

    expect(signatureHeader.toString(), correct);
  });

  test("parses signature header", () {
    final correct = SignatureHeader(
      keyId: "rsa-key-1",
      algorithm: "rsa-sha256",
      signatureHeaders: [
        "(request-target)",
        "host",
        "date",
        "digest",
        "content-length"
      ],
      signature: "rsa-signature-1",
    );
    final check = SignatureHeader.parse(
      'Signature keyId="rsa-key-1",algorithm="rsa-sha256",headers="(request-target) host date digest content-length",signature="rsa-signature-1"',
    );

    expect(check, correct);
  });
}
