import {LightningElement, wire, track, api} from 'lwc';
import getSMSCallout from "@salesforce/apex/TwillioHttpCallout.sendCustomSMS";
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Account.Mobile__c', 'Account.Phone'];

const options = [{
        label: 'Phone',
        value: 'Phone'
    },
    {
        label: 'Mobile',
        value: 'Mobile'
    },
    {
        label: 'Other',
        value: 'Other: Please Enter'
    }
]

export default class SendCustomSMS extends LightningElement {
    @api recordId;
    @track numberType;
    @track toNumberValue = '';
    @track toNum;
    @track optionValue;
    @track options = options;
     @track mobile;
     @track phone;
    @track data;
    @track messageBody ='';


    @wire(getRecord, {recordId: "$recordId", fields: FIELDS}) 
    wireNumbers({error, data}) {
        if (error) {
            processError(this, error);
        } else if (data) {
            this.data = data;
            this.mobile = data.fields.Mobile__c.value;
            this.phone = data.fields.Phone.value;
        }
    }

    handleSmsBody(event) {
        this.messageBody = event.detail.value;
    }

    handlePhoneValueChange(event) {
        this.toNum = event.detail.value;
        if (this.toNum == this.phone) {
            this.numberType = 'Phone';

        } else if (this.toNum == this.mobile) {
            this.numberType = 'Mobile';

        } else {
            this.numberType = 'Other: Please Enter';

        }
        this.toNumberValue = event.detail.value;
    }

    handlePhoneChange(event) {

        try {
            this.optionValue = event.detail.value;
            if (this.optionValue == 'Phone') {
                this.toNumberValue = this.phone;

            } else if (this.optionValue == 'Mobile') {
                this.toNumberValue = this.mobile;

            } else {
                this.toNumberValue = '';
            }

        } catch (error) {
            console.error();
        }
    }

    handleSmsSend() {
        try {
            if (this.messageBody == '' && this.toNumberValue == '') {
                this.toastMessage('info', 'Enter a message and number');

            } else if (!this.messageBody) {
                this.toastMessage('info', 'Enter a message');

            } else if (!this.toNumberValue) {
                this.toastMessage('info', 'Enter a \'To number\'');

            } else {
                getSMSCallout({
                        messageBody: this.messageBody,
                        toNumber: this.toNumberValue,
                        accountId: this.recordId
                    })
                    .then(data => {
                        if (data.status) {
                            if (data.status == '400') {
                                this.toastMessage('error', data.message);

                            } else if (data.status == '200') {
                                this.toastMessage('success', data.status);
                            } else if (data.status == 'queued') {
                                this.toastMessage('success', data.status);

                            } else if (data.status == 'accepted') {
                                this.toastMessage('success', data.status);
                            }
                        }
                    })
                    
            }
        } catch (error) {
            console.error();
            
        }
    }

    clearFields() {

this.template.querySelectorAll('lightning-textarea, lightning-input, lightning-combobox').forEach((input) => { input.value = ''; });
   }

   toastMessage(status, message){
       if (status == 'success'){
        const evt = new ShowToastEvent({
            title: "Sms Sent",
            message: 'Sms sent. Status: ' + message,
            variant: 'success',
        });
        this.dispatchEvent(evt).clearFields();
        setTimeout(() => {
            this.clearFields();
        }, 1280);
       }
       else if (status == 'error'){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Sms send failed. Error: ' + message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
       }
       else if (status == 'info'){
        const evt = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: 'info',
        });
        this.dispatchEvent(evt);
   }
   
}


}