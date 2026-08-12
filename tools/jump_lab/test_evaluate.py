import unittest

from evaluate import evaluate


class EvaluateTest(unittest.TestCase):
    def test_matches_once_and_reports_detection_and_metric_errors(self) -> None:
        reference = {
            "session": {"source": "reference"},
            "jumps": [
                {"id": "r1", "event_time_s": 10.0, "height_m": 3.0},
                {"id": "r2", "event_time_s": 20.0, "height_m": 5.0},
            ],
        }
        candidate = {
            "session": {"source": "windwisher"},
            "jumps": [
                {"id": "c1", "event_time_s": 10.2, "height_m": 3.1},
                {"id": "c2", "event_time_s": 40.0, "height_m": 8.0},
            ],
        }

        report = evaluate(
            reference,
            candidate,
            max_time_delta=1.0,
            tolerances={"height_m": 0.25, "airtime_s": 0.25, "distance_m": 3.0},
        )

        self.assertEqual(report["matched_jumps"], 1)
        self.assertEqual(report["false_positives"], 1)
        self.assertEqual(report["false_negatives"], 1)
        self.assertAlmostEqual(report["f1"], 0.5)
        self.assertAlmostEqual(report["metrics"]["height_m"]["mae"], 0.1)
        self.assertEqual(report["metrics"]["height_m"]["within_tolerance"], 1)


if __name__ == "__main__":
    unittest.main()
