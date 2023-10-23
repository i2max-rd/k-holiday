@isTest
public class PublicHolidayNoResultWrapperTest {
    @isTest
    static void testParse() {
        String json = '{\"response\":{\"header\":{\"resultCode\":\"00\",\"resultMsg\":\"NORMAL SERVICE.\"},\"body\":{\"items\":\"\",\"numOfRows\":10,\"pageNo\":1,\"totalCount\":0}}}';
        PublicHolidayNoResultWrapper obj = PublicHolidayNoResultWrapper.parse(json);
        System.assert(obj != null);
    }
}