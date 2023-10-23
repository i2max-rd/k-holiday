public class PublicHolidayNoResultWrapper {
    public class Response {
        public Header header;
        public Body body;
    }

    public Response response;

    public class Header {
        public String resultCode;
        public String resultMsg;
    }

    public class Body {
        public String items;
        public Integer numOfRows;
        public Integer pageNo;
        public Integer totalCount;
    }

    public static PublicHolidayNoResultWrapper parse(String json) {
        return (PublicHolidayNoResultWrapper) System.JSON.deserialize(json, PublicHolidayNoResultWrapper.class);
    }
}