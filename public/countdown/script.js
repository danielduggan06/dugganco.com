const daysEl = document.getElementById('days')
const hoursEl = document.getElementById('hours')
const minsEl = document.getElementById('mins')
const secondsEl = document.getElementById('seconds')

const thanksGiving = "December 25 2023";

function countdown() {
    const thanksgivingDate = new Date(thanksGiving);
    var currentDate = new Date();

    const totalSeconds = (thanksgivingDate - currentDate) / 1000;

    var days = Math.floor(totalSeconds / 3600 / 24);
    var hours = Math.floor(totalSeconds / 3600) % 24;
    var mins = Math.floor(totalSeconds / 60) % 60;
    var seconds = Math.floor(totalSeconds) % 60;

    daysEl.innerHTML = days;
    hoursEl.innerHTML = formatTime(hours);
    minsEl.innerHTML = formatTime(mins);
    secondsEl.innerHTML = formatTime(seconds);
}

function formatTime(time) {
    return time < 10 ? `0${time}` : time;
}

//initial call
countdown();

setInterval(countdown, 1000);
