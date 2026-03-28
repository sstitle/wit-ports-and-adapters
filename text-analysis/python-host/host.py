from wasmtime import Store, Engine

# Import generated bindings (run step 2 in README to produce text_analysis/).
from text_analysis import Root
from text_analysis.types import Ok, Err


SAMPLE_TEXT = """
To be or not to be that is the question
Whether tis nobler in the mind to suffer
the slings and arrows of outrageous fortune
or to take arms against a sea of troubles
And by opposing end them to die to sleep
No more and by a sleep to say we end
The heartache and the thousand natural shocks
That flesh is heir to tis a consummation
Devoutly to be wished to die to sleep
To sleep perchance to dream ay there the rub
For in that sleep of death what dreams may come
When we have shuffled off this mortal coil
Must give us pause there is the respect
That makes calamity of so long life
"""


def main():
    store = Store(Engine())
    root = Root(store)

    analyzer = root.analyzer()
    result = analyzer.analyze(store, SAMPLE_TEXT, 5)

    # Development: inspect the raw return type before unwrapping
    print(f"Raw return type: {type(result)}")
    print(f"Raw return value: {result!r}")
    print()

    if isinstance(result, Ok):
        r = result.value
        print(f"Total words:  {r.total_words}")
        print(f"Unique words: {r.unique_words}")
        print("Top words:")
        for stat in r.top_words:
            print(f"  {stat.word!r}: {stat.count}")
    elif isinstance(result, Err):
        print(f"Component returned an error: {result.value}")


if __name__ == "__main__":
    main()
