const quizData = [
    {
        question: 'How old is Daniel?',
        a: '34',
        b: '30',
        c: 'beekeeping age',
        d: '27',
        correct: 'b'
    },
    {
        question: 'Of the following countries, which is the largest by population?',
        a: 'Phillipines',
        b: 'Egypt',
        c: 'Iran',
        d: 'Bangladesh',
        correct: 'd'
    },
    {
        question: 'Who is the youngest of the following rock stars from the 70s and 60s?',
        a: 'Steven Tyler',
        b: 'Mick Jagger',
        c: 'Pete Townshend',
        d: 'Robert Plant',
        correct: 'd'
    },
    {
        question: 'Who is the only player to win Super Bowl MVP as a special teams player?',
        a: 'Adam Vinatieri',
        b: 'Julian Edelman',
        c: 'Desmond Howard',
        d: 'Devin Hester',
        correct: 'c'
    },
    {
        question: 'Of the following United States cities, which has the highest cost of living (according to CNBC)?',
        a: 'Brooklyn, NY',
        b: 'Honolulu, HI',
        c: 'San Fransisco, CA',
        d: 'Long Beach, CA',
        correct: 'b'
    }
];

const quiz = document.getElementById("quiz");
const answerEls = document.querySelectorAll(".answer");
const questionEl = document.getElementById("question");
const a_text = document.getElementById("a_text");
const b_text = document.getElementById("b_text");
const c_text = document.getElementById("c_text");
const d_text = document.getElementById("d_text");
const submitBtn = document.getElementById("submit");

let currentQuiz = 0;
let score = 0;

loadQuiz();

function loadQuiz() {
    deselectAnswers();

    const currentQuizData = quizData[currentQuiz];

    questionEl.innerText = currentQuizData.question;
    a_text.innerText = currentQuizData.a;
    b_text.innerText = currentQuizData.b;
    c_text.innerText = currentQuizData.c;
    d_text.innerText = currentQuizData.d;
}

function getSelected() {
    let answer = undefined;

    answerEls.forEach((answerEl) => {
        if (answerEl.checked) {
            answer = answerEl.id;
        }
    });

    return answer;
}

function deselectAnswers() {
    answerEls.forEach((answerEl) => {
        answerEl.checked = false;
    });
}

submitBtn.addEventListener("click", () => {
    // check to see the answer
    const answer = getSelected();

    if (answer) {
        if (answer === quizData[currentQuiz].correct) {
            score++;
        }

        currentQuiz++;
        if (currentQuiz < quizData.length) {
            loadQuiz();
        } else {
            quiz.innerHTML = `
                <h2>You had ${score} correct answers out of ${quizData.length} questions.</h2>
                
                <button onclick="location.reload()">Reload</button>
            `;
        }
    }
});
