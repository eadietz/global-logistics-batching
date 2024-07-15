from clingo.backend import Observer

class MyObserver(Observer):
    def __init__(self):
        self.number_rules = 0
        self.number_choice_rules = 0
        self.list_of_rules = []

    def start(self):
        self.number_rules = 0

    def rule(self, choice, head, body):
        self.list_of_rules.append([choice, head, body])
        if choice:
            self.number_choice_rules += 1
        self.number_rules += 1
