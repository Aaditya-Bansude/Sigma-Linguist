import xml.etree.ElementTree as ET
import pandas as pd

replacements = [
    ("can you", "could you please"),
    ("i need", "assistance is required"),
    ("send", "forward"),
    ("give me", "provide me with"),
    ("let's", "shall we"),
    ("tell me", "inform me"),
    ("want", "would like to"),
    ("help", "assistance"),
    ("get", "receive"),
    ("show", "demonstrate"),
    ("ask", "request"),
    ("do you know", "are you aware"),
    ("how to", "the procedure to"),
    ("why not", "what would be the reason not to"),
    ("what's", "what is"),
    ("let me know", "please inform me"),
    ("make sure", "ensure"),
    ("talk", "discuss"),
    ("find out", "ascertain"),
    ("I'll", "I will"),
    ("you'll", "you will"),
    ("we'll", "we will"),
    ("you're", "you are"),
    ("I'm", "I am"),
    ("we're", "we are"),
    ("it's", "it is"),
    ("can't", "cannot"),
    ("won't", "will not"),
    ("don't", "do not"),
    ("haven't", "have not"),
    ("isn't", "is not"),
    ("wasn't", "was not"),
    ("weren't", "were not"),
    ("let", "allow"),
    ("need to", "are required to"),
    ("going to", "intending to"),
    ("have to", "must"),
    ("look into", "investigate"),
    ("put off", "postpone"),
    ("turn in", "submit"),
    ("work on", "address"),
    ("think about", "consider"),
    ("figure out", "determine"),
    ("call", "contact"),
    ("meeting", "appointment"),
    ("talk about", "discuss"),
    ("get back to me", "revert"),
    ("let me know", "apprise me"),
    ("find", "locate"),
    ("fix", "resolve"),
    ("start", "commence"),
    ("finish", "complete"),
    ("go over", "review"),
    ("point out", "indicate"),
    ("give", "provide"),
    ("take care of", "handle"),
    ("make a decision", "determine"),
    ("get in touch with", "contact"),
    ("set up", "arrange"),
    ("look over", "examine"),
    ("get ready for", "prepare for"),
    ("hand in", "submit"),
    ("come up with", "develop")
]


def parse_xml_to_dataframe(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    data = {'subject': [], 'question': [], 'best_answer': [], 'answers': []}

    for document in root.findall('.//document'):
        subject = document.find('subject').text if document.find('subject') is not None else ""
        question = document.find('content').text if document.find('content') is not None else ""
        best_answer = document.find('bestanswer').text if document.find('bestanswer') is not None else ""
        answers = [answer_item.text for answer_item in document.findall('.//answer_item')]

        subject = subject.strip()
        question = question.strip()
        best_answer = best_answer.strip()
        answers = [answer.strip() for answer in answers]

        data['subject'].append(subject)
        data['question'].append(question)
        data['best_answer'].append(best_answer)
        data['answers'].append(answers)

    return pd.DataFrame(data)


def parse_corporate_keywords(text):
    for normal, corporate in replacements:
        text = text.replace(normal, corporate)
    return text

# Parse the XML file and convert to DataFrame
df = parse_xml_to_dataframe('dataset.xml')

# Save the DataFrame to a CSV file
df.to_csv('preprocessed_data.csv', index=False)

print("Preprocessed data saved to 'preprocessed_data.csv'")


# Save the DataFrame to a CSV file
df.to_csv('preprocessed_data.csv', index=False)

print("Preprocessed data saved to 'preprocessed_data.csv'")


data = pd.read_csv('yahoo_l6.csv')
# Extract questions and answers
questions = data['question'].tolist()
answers = data['answer'].tolist()
# preprocess.py





# Parse the XML file and convert to DataFrame
df = parse_xml_to_dataframe('dataset.xml')

# Save the DataFrame to a CSV file
df.to_csv('preprocessed_data.csv', index=False)

print("Preprocessed data saved to 'preprocessed_data.csv'")


# Example of preprocessing (you may need more sophisticated cleaning based on your data)
def preprocess_text(text):
    text = text.strip().lower()  # Example preprocessing: strip and lowercase
    return text


questions = [preprocess_text(q) for q in questions]
answers = [preprocess_text(a) for a in answers]


# Example: Create synthetic corporate language
def make_corporate(text):
    for normal, corporate in replacements:
        text = text.replace(normal, corporate)
    return text


# List of (normal, corporate) pairs


# Generate pairs
dataset = []
for q, a in zip(questions, answers):
    normal_phrase = q
    corporate_phrase = make_corporate(q)  # Simplified example
    dataset.append((normal_phrase, corporate_phrase))

# Convert to DataFrame for easier handling
df = pd.DataFrame(dataset, columns=['normal', 'corporate'])
