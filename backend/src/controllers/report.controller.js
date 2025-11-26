const Report = require('../models/Report');

class ReportController {
  async createReport(req, res, next) {
    try {
      const { reported, reason, description } = req.body;

      // Check if already reported
      const existingReport = await Report.findOne({
        reporter: req.userId,
        reported: reported
      });

      if (existingReport) {
        return res.status(400).json({
          success: false,
          error: 'Already reported this user'
        });
      }

      const report = await Report.create({
        reporter: req.userId,
        reported: reported,
        reason: reason,
        description: description
      });

      res.status(201).json({
        success: true,
        data: { report }
      });
    } catch (error) {
      next(error);
    }
  }

  async getReports(req, res, next) {
    try {
      const { status, page = 1, limit = 20 } = req.query;
      const query = {};
      if (status) {
        query.status = status;
      }

      const reports = await Report.find(query)
        .populate('reporter', 'firstName lastName email')
        .populate('reported', 'firstName lastName email')
        .sort({ createdAt: -1 })
        .limit(limit * 1)
        .skip((page - 1) * limit);

      const total = await Report.countDocuments(query);

      res.json({
        success: true,
        data: {
          reports,
          pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            total,
            pages: Math.ceil(total / limit)
          }
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async updateReportStatus(req, res, next) {
    try {
      const { status } = req.body;
      const report = await Report.findByIdAndUpdate(
        req.params.reportId,
        {
          status: status,
          reviewedBy: req.userId,
          reviewedAt: new Date()
        },
        { new: true }
      );

      if (!report) {
        return res.status(404).json({
          success: false,
          error: 'Report not found'
        });
      }

      res.json({
        success: true,
        data: { report }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ReportController();

