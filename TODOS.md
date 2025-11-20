# Todos

* sometimes the address page doesn't work
* we need to deploy the server somewhere
* we need to track the submissions.



## Idea: How to track the submissions
1. Client needs a CLIENT submission queue
2. When client sends photo, it should save the submission.
3. Then a queue worker bot tries to send the submissions to the server. the server should respond right away with a pimbl ID.
4. The Server should respond to a request with a pimbl ID, save the submission to a SERVER submission queue and respond with a pimbl id. (the pimbl ID can index all submissions the server receives.)
5. Server should have a worker bot sending the submissions to 311. And then have a submission status of the pimbl id (queued, processing, submitted, failed)
6. Server should expose a getStatusByPimblID which returns the information about the pimbl ID request.



