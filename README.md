# http_signature_helper

Signature helpers from the [HTTP Signature spec](https://tools.ietf.org/id/draft-cavage-http-signatures-10.html).


## Usage

```dart
import 'package:http_signature_helper/http_signature_helper.dart';

main() {
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

  print(signatureString);
  // (request-target): get /foo\nhost: example.org\ndate: Tue, 07 Jun 2014 20:51:35 GMT\ncache-control: max-age=60, must-revalidate\nx-example: Example header with some whitespace.\nbody

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

  print(signatureHeader);
  // Signature keyId="rsa-key-1",algorithm="rsa-sha256",headers="(request-target) host date digest content-length",signature="rsa-signature-1"

  final signatureHeader2 = SignatureHeader.parse(signatureHeader.toString());

  print(signatureHeader == signatureHeader2);
  // true
}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Cretezy/http_signature_helpers.dart/issues
