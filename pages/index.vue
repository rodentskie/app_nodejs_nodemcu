<template>
  <div>
    <b-card no-body class="mt-5" style="margin:10px;padding:10px;">
      <!-- image to trigger -->
      <img class="login_header" :src="imgSource" />
      <!-- button -->
      <b-button class="login" variant="light-green" @click="triggerLed">{{
        btnText
      }}</b-button>

      <br />
      <br />
      <div>
        <!-- filters -->
        <b-row class="mb-3">
          <b-col lg="12" md="8" sm="8" class="mb-3 mt-2">
            <b-button
              id="add-module"
              variant="success"
              size="sm"
              class="main-button"
              @click="refreshLogs"
            >
              <font-awesome-icon
                style="color:white"
                icon="recycle"
                small
                class="icon"
              />&nbsp; Reload Logs
            </b-button>
          </b-col>
          <b-col cols="5" lg="5" md="5" sm="5" class="mb-2">
            <!-- dummy column -->
          </b-col>
          <b-col cols="5" lg="5" md="5" sm="5" class="mb-2">
            <!-- dummy column -->
          </b-col>
          <b-col cols="2" lg="2" md="2" sm="3" class="items">
            <b-input-group prepend="Items" size="sm">
              <b-form-select style="z-index:0" size="sm" v-model="perPage">
                <option v-for="value in values" :key="value" :value="value">{{
                  value
                }}</option>
                <option :value="filterItems.length">All</option>
              </b-form-select>
            </b-input-group>
          </b-col>
        </b-row>
        <!-- end filters -->

        <!-- table -->
        <b-table
          class="mt-2"
          ref="display-items-table"
          id="display-items-table"
          :borderless="false"
          :items="filterItems"
          :filter="filter"
          :fields="fields"
          selectedVariant="primary"
          responsive
          show-empty
          :per-page="perPage"
          :current-page="currentPage"
          sort-by="id"
          :sort-desc="true"
        >
          <template v-slot:table-caption>{{ bottomLabel }}</template>
        </b-table>
        <!-- end table -->

        <!-- pagination -->
        <div class="mt-5">
          <b-pagination
            v-if="filterItems.length !== 0"
            id="pagination"
            align="center"
            v-model="currentPage"
            :total-rows="totalRows"
            :per-page="perPage"
            class="my-0"
            size="sm"
            pills
          ></b-pagination>
        </div>
        <!-- end pagination -->
      </div>
    </b-card>
  </div>
</template>

<script>
import io from "socket.io-client";
import moment from "moment";

export default {
  head() {
    return {
      title: `NodeMCU Socket IO`,
      meta: [
        {
          hid: "NodeMCU Socket IO",
          name: "NodeMCU Socket IO",
          content: "NodeJS NodeMCU Socket IO."
        }
      ]
    };
  },
  data() {
    return {
      btnText: `TURN ON`,
      imgSource: `/bulb_off.png`,
      socket: null,
      //   for table
      filter: null,
      perPage: 5,
      values: ["5", "10", "25", "50", "100"],
      items: [],
      currentPage: 1,
      fields: [
        {
          key: "id",
          label: "ID",
          sortable: true
        },
        {
          key: "lastModify",
          label: "Last Modified",
          sortable: true
        },
        {
          key: "triggeredThru",
          label: "Triggered Through",
          sortable: false
        }
      ],
      totalRows: null
      //   end for table
    };
  },
  created() {
    this.connectToServer();
  },
  methods: {
    refreshLogs() {
      this.socket.emit("logs"); // tell server to return logs
    },
    triggerLed() {
      if (this.btnText == `TURN ON`) {
        this.socket.emit("1"); // turn on; throw to server;
      } else {
        this.socket.emit("0"); // turn off;  throw to server;
      }
      this.socket.emit("logs"); // tell server to return logs
    },
    connectToServer() {
      this.socket = io.connect(process.env.socketUrl, { secure: true }); //connect to server
      // server replies
      this.socket.on("message", data => {
        if (data.value == 0) {
          this.btnText = `TURN ON`;
          this.imgSource = `/bulb_off.png`;
        }
        if (data.value == 1) {
          this.btnText = `TURN OFF`;
          this.imgSource = `/bulb_on.png`;
        }
      });

      // server replies
      this.socket.on("msg", data => {
        if (data.value == 0) {
          this.btnText = `TURN ON`;
          this.imgSource = `/bulb_off.png`;
        }
        if (data.value == 1) {
          this.btnText = `TURN OFF`;
          this.imgSource = `/bulb_on.png`;
        }
      });

      this.socket.emit("logs"); // tell server to return logs

      // server replies
      this.socket.on("logs", data => {
        this.items = []; // clear
        for (let i = 0; i < data.length; i++) {
          const e = data[i];
          this.items.push({
            id: e.id,
            triggeredThru: e.triggeredThru,
            lastModify: moment(e.createdAt).format(`MMM DD, YYYY hh:mm:ss A`)
          });
        }
      });
    }
  },
  computed: {
    filterItems() {
      const items = this.items.filter(e => {
        return true;
      });
      this.totalRows = items.length;

      return items;
    },
    bottomLabel() {
      let end = this.perPage * this.currentPage;
      let start = end - this.perPage + 1;

      if (end > this.filterItems.length) {
        end = this.filterItems.length;
      }
      if (this.filterItems.length === 0) {
        start = 0;
      }
      return `Showing ${start} to ${end} of ${this.filterItems.length} entries`;
    }
  }
};
</script>

<style></style>
