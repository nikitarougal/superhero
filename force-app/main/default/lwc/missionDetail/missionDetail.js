import { LightningElement, track, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import MISSION_CHANNEL from "@salesforce/messageChannel/MissionMessageChannel__c";

import getMissionDetails from "@salesforce/apex/MissionDetailController.getMissionDetails";

export default class MissionDetail extends LightningElement {
  subscription = null;
  missionId;
  missionDetails;

  @track placeholderMessage;

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        MISSION_CHANNEL,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  // Handler for message received by component
  handleMessage(message) {
    getMissionDetails({
      recormissionId: message.recordId
    })
      .then((result) => {
        this.missionDetails = result;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }
}
