public class PublicHolidayInvocableTestMockNoResult implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json; charset=UTF-8');
        res.setBody(
            '{"response":{"header":{"resultCode":"00","resultMsg":"NORMAL SERVICE."},"body":{"items":"","numOfRows":10,"pageNo":1,"totalCount":0}}}'
        );
        res.setStatusCode(200);
        return res;
    }
}