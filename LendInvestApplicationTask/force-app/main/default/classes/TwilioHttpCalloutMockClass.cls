@IsTest
global class TwilioHttpCalloutMockClass implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        System.assertEquals('POST', req.getMethod());
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{"Test Response":["Message","One"]}');
        res.setStatusCode(201);
        
        return res;
    }
}