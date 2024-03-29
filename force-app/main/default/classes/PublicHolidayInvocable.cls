@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class PublicHolidayInvocable {
    global class KHolidayException extends Exception {
    }

    @InvocableMethod(label='KR Public Holiday' description='공공데이터포털조회' category='Calendar' callout=true)
    global static void getHolidayInfo(List<Requests> params) {
        upsertHolidays(params[0].dt);
    }

    @future(callout=true)
    global static void upsertHolidays(Date dt) {
        try {
            KHolidayCredentials__c publicApiCredential = KHolidayCredentials__c.getOrgDefaults();

            if (publicApiCredential == null || publicApiCredential.ServiceKey__c == null) {
                throw new KHolidayException('Missing service key');
            }

            String endpoint = 'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo';
            String serviceKey = publicApiCredential.ServiceKey__c;

            String solYear = String.valueOf(dt.year());
            String solMonth = String.valueOf(dt.month()).leftPad(2, '0');

            String compose =
                '?serviceKey=' +
                EncodingUtil.urlEncode(serviceKey, 'UTF-8') +
                '&solYear=' +
                EncodingUtil.urlEncode(solYear, 'UTF-8') +
                '&solMonth=' +
                EncodingUtil.urlEncode(solMonth, 'UTF-8') +
                '&_type=json';

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint + compose);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Http h = new Http();
            HttpResponse response = h.send(request);

            List<Holiday> holidays = new PublicHolidayBuilder(response.getBody()).build();

            if (holidays == null || holidays.size() == null) {
                return;
            }

            Date currentMonthFisrtDay = Date.newInstance(dt.year(), dt.month(), 1);
            Date nextMonthFirstDay = currentMonthFisrtDay.addMonths(1);

            Set<String> nameDtSet = new Set<String>();

            for (Holiday h1 : [
                SELECT Name, ActivityDate
                FROM Holiday
                WHERE ActivityDate >= :currentMonthFisrtDay AND ActivityDate < :nextMonthFirstDay
                WITH SYSTEM_MODE
            ]) {
                nameDtSet.add(h1.Name + h1.ActivityDate);
            }

            List<Holiday> holidayToInsert = new List<Holiday>();

            for (Holiday h2 : holidays) {
                if (!nameDtSet.contains(h2.Name + h2.ActivityDate)) {
                    holidayToInsert.add(h2);
                }
            }

            insert as system holidayToInsert;
        } catch (Exception e) {
            throw new KHolidayException(e.getMessage());
        }
    }

    global class Requests {
        @InvocableVariable(label='날짜' description='date' required=true)
        global Date dt;
    }
}