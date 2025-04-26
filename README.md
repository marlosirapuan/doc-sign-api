# doc-sign-api

Small API project to sign document with attachment

### Getting started

Create a new credentials and generate master key

  ```bash
  rm config/credentials.yml.enc config/master.key
  EDITOR="vi" rails credentials:edit
  ```

Close with `:wq` and follow steps below


### How start application

1) Run app:

  ```bash
  docker compose up app
  ```

2) Get a token (need run seed before):

  ```bash
  curl -X POST http://localhost:3000/login -H \
    "Content-Type: application/json" \
    -d '{"email":"user1@example.com","password":"password123"}'
  ```

3) Sign document for user (replace authorization bearer token):

  PDF:
  ```bash
  curl -X POST http://localhost:3000/documents \
    -H "Authorization: Bearer TOKEN_HERE" \
    -F "file=@example_pdf.pdf" \
    -F "signature=@example_signature.png" \
    -F "signature_x=100" \
    -F "signature_y=150"
  ```

  DOCX:
  ```bash
  curl -X POST http://localhost:3000/documents \
    -H "Authorization: Bearer TOKEN_HERE" \
    -F "file=@example_doc.docx" \
    -F "signature=@example_signature.png" \
    -F "signature_x=100" \
    -F "signature_y=150"
  ```

4) View document signed:

  ```bash
  docker compose run --rm app rails c

  User.first.documents.first.file_path
  ```

  or access path:

  ```
  /app/storage/example_signed.pdf
  ```

### How run tests

Run tests:

  ```bash
  docker compose up test
  ```

  or

  ```bash
  docker compose run --rm test
  ```
