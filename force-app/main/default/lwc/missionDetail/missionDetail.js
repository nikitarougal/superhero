import { LightningElement, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext,
  publish
} from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import missionMessageChannel from "@salesforce/messageChannel/MissionMessageChannel__c";
import getMissionDetails from "@salesforce/apex/MissionDetailController.getMissionDetails";
import getHeroDetails from "@salesforce/apex/MissionDetailController.getHeroDetails";
import checkHeroMissionAssignments from "@salesforce/apex/MissionDetailController.checkHeroMissionAssignments";
import getAllPossibleRanks from "@salesforce/apex/MissionDetailController.getAllPossibleRanks";
import createMissionAssignment from "@salesforce/apex/MissionDetailController.createMissionAssignment";
import updateMissionAssignment from "@salesforce/apex/MissionDetailController.updateMissionAssignment";

const acceptLabel = "Accept";
const completeLabel = "Complete";
const buttonBrandVariant = "brand";
const buttonOutlineVariant = "brand-outline";
const requestToSelectAMissionLabel = "Select a mission to learn more about it";
const matchRankError =
  "Unfortunately, you're currently too weak to take on this task. Return when you reach the rank of";
const tooManyMissionsError = "You have too many unfinished missions";

export default class MissionDetail extends LightningElement {
  subscription = null;
  superheroMission;
  heroDetails;
  isLoaded = false;
  buttonLabel;
  buttonVariant;
  showButton = true;
  requestToSelectAMissionLabel = requestToSelectAMissionLabel;

  toastTitle = "Error";
  errorVariant = "error";
  errorMode = "sticky";

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        missionMessageChannel,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  async handleMessage(message) {
    this.heroDetails = await getHeroDetails();
    getMissionDetails({
      recordId: message.recordId,
      heroId: this.heroDetails.id
    })
      .then((result) => {
        this.superheroMission = result;
        this.setButtonLabel();
        this.isLoaded = true;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  setButtonLabel() {
    if (this.superheroMission.status) {
      if (this.superheroMission.status === "In Progress") {
        this.buttonLabel = completeLabel;
        this.buttonVariant = buttonOutlineVariant;
        this.showButton = true;
      } else {
        this.buttonLabel = "";
        this.showButton = false;
      }
    } else {
      this.buttonLabel = acceptLabel;
      this.buttonVariant = buttonBrandVariant;
      this.showButton = true;
    }
  }

  handleClick(event) {
    const actionType = event.target.label;
    if (actionType === acceptLabel) {
      this.handleAccept(actionType);
    }

    if (actionType === completeLabel) {
      this.handleMission(actionType);
    }
  }

  async handleAccept(actionType) {
    var isHeroAvailableForNewMission, isHeroRankMatch;
    try {
      const { id, rank } = this.heroDetails;
      isHeroAvailableForNewMission = await checkHeroMissionAssignments({
        heroId: id
      });
      isHeroRankMatch = await this.checkHeroRankMatch(rank);
    } catch (error) {
      console.log(error.body.message);
      return;
    }

    if (isHeroRankMatch != null && !isHeroRankMatch) {
      return this.showToast(
        this.errorVariant,
        this.toastTitle,
        matchRankError + " " + this.superheroMission.rank,
        this.errorMode
      );
    } else if (
      isHeroAvailableForNewMission != null &&
      !isHeroAvailableForNewMission
    ) {
      return this.showToast(
        this.errorVariant,
        this.toastTitle,
        tooManyMissionsError,
        this.errorMode
      );
    }
    return this.handleMission(actionType);
  }

  async checkHeroRankMatch(rank) {
    const ranks = await getAllPossibleRanks();
    const index = ranks.findIndex(
      (value) => value === this.superheroMission.rank
    );
    const availableRanks = [ranks[index - 1], ranks[index], ranks[index + 1]];
    return availableRanks.includes(rank);
  }

  async handleMission(actionType) {
    try {
      const { id } = this.superheroMission;
      const response =
        actionType === "Accept"
          ? await createMissionAssignment({
              heroId: this.heroDetails.id,
              missionId: id
            })
          : await updateMissionAssignment({
              heroId: this.heroDetails.id,
              missionId: id
            });

      if (response) {
        let message = { recordId: id };
        publish(this.messageContext, missionMessageChannel, message);
      }
    } catch (error) {
      console.log(error.body.message);
    }
  }

  showToast(variant, title, message, mode) {
    const event = new ShowToastEvent({ title, variant, message, mode });
    this.dispatchEvent(event);
  }
}
